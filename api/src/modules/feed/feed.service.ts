import { Types } from 'mongoose';
import { HttpError } from '../../middleware/error';
import { User } from '../auth/user.model';
import { Profile } from '../profile/profile.model';
import {
  Comment,
  Post,
  PostDoc,
  PostLike,
  PostSave,
  PostType,
} from './feed.model';

type AuthorSnippet = {
  id: string;
  name: string;
  avatarUrl?: string;
  role?: string;
  city?: string;
};

async function buildAuthorMap(userIds: string[]): Promise<Map<string, AuthorSnippet>> {
  if (userIds.length === 0) return new Map();
  const oids = userIds.map((id) => new Types.ObjectId(id));
  const [users, profiles] = await Promise.all([
    User.find({ _id: { $in: oids } }),
    Profile.find({ userId: { $in: oids } }),
  ]);
  const profileMap = new Map(profiles.map((p) => [p.userId.toString(), p]));
  const out = new Map<string, AuthorSnippet>();
  for (const u of users) {
    const p = profileMap.get(u.id as string);
    out.set(u.id as string, {
      id: u.id as string,
      name: u.name,
      avatarUrl: p?.bio?.avatarUrl ?? u.avatarUrl,
      role: p?.workDetails?.jobRole,
      city: p?.personalDetails?.currentLocation ?? u.city,
    });
  }
  return out;
}

function serializePost(
  post: PostDoc,
  author: AuthorSnippet | undefined,
  viewer: { liked: boolean; saved: boolean }
) {
  return {
    id: post._id.toString(),
    type: post.type,
    title: post.title,
    body: post.body,
    imageUrl: post.imageUrl,
    createdAt: post.createdAt,
    counts: {
      likes: post.likesCount,
      comments: post.commentsCount,
    },
    viewer,
    author: author ?? {
      id: post.authorId.toString(),
      name: 'Unknown',
    },
  };
}

export async function listFeed(
  userId: string,
  opts: { type?: PostType; cursor?: string; limit: number }
) {
  const filter: Record<string, unknown> = {};
  if (opts.type) filter.type = opts.type;
  if (opts.cursor) {
    filter._id = { $lt: new Types.ObjectId(opts.cursor) };
  }

  const posts = await Post.find(filter)
    .sort({ _id: -1 })
    .limit(opts.limit + 1);

  const hasMore = posts.length > opts.limit;
  const trimmed = hasMore ? posts.slice(0, opts.limit) : posts;
  const nextCursor = hasMore ? trimmed[trimmed.length - 1].id : null;

  const postIds = trimmed.map((p) => p._id);
  const authorIds = Array.from(new Set(trimmed.map((p) => p.authorId.toString())));
  const viewerOid = new Types.ObjectId(userId);

  const [authors, likes, saves] = await Promise.all([
    buildAuthorMap(authorIds),
    PostLike.find({ postId: { $in: postIds }, userId: viewerOid }),
    PostSave.find({ postId: { $in: postIds }, userId: viewerOid }),
  ]);

  const likedSet = new Set(likes.map((l) => l.postId.toString()));
  const savedSet = new Set(saves.map((s) => s.postId.toString()));

  const items = trimmed.map((p) =>
    serializePost(p, authors.get(p.authorId.toString()), {
      liked: likedSet.has(p._id.toString()),
      saved: savedSet.has(p._id.toString()),
    })
  );

  return { items, nextCursor };
}

export async function getPost(userId: string, postId: string) {
  const post = await Post.findById(postId);
  if (!post) throw new HttpError(404, 'Post not found');

  const viewerOid = new Types.ObjectId(userId);
  const [authors, liked, saved] = await Promise.all([
    buildAuthorMap([post.authorId.toString()]),
    PostLike.findOne({ postId: post._id, userId: viewerOid }),
    PostSave.findOne({ postId: post._id, userId: viewerOid }),
  ]);

  return serializePost(post, authors.get(post.authorId.toString()), {
    liked: !!liked,
    saved: !!saved,
  });
}

export async function createPost(
  userId: string,
  input: { type: PostType; title?: string; body: string; imageUrl?: string }
) {
  const post = await Post.create({
    authorId: new Types.ObjectId(userId),
    type: input.type,
    title: input.title,
    body: input.body,
    imageUrl: input.imageUrl,
  });
  return getPost(userId, post._id.toString());
}

export async function deletePost(userId: string, postId: string) {
  const post = await Post.findById(postId);
  if (!post) throw new HttpError(404, 'Post not found');
  if (post.authorId.toString() !== userId) throw new HttpError(403, 'Not your post');
  await Promise.all([
    Post.deleteOne({ _id: post._id }),
    PostLike.deleteMany({ postId: post._id }),
    PostSave.deleteMany({ postId: post._id }),
    Comment.deleteMany({ postId: post._id }),
  ]);
}

export async function toggleLike(userId: string, postId: string) {
  const post = await Post.findById(postId);
  if (!post) throw new HttpError(404, 'Post not found');
  const uid = new Types.ObjectId(userId);
  const existing = await PostLike.findOne({ postId: post._id, userId: uid });
  if (existing) {
    await existing.deleteOne();
    await Post.updateOne({ _id: post._id }, { $inc: { likesCount: -1 } });
    return { liked: false, likesCount: Math.max(0, post.likesCount - 1) };
  }
  await PostLike.create({ postId: post._id, userId: uid });
  await Post.updateOne({ _id: post._id }, { $inc: { likesCount: 1 } });
  return { liked: true, likesCount: post.likesCount + 1 };
}

export async function toggleSave(userId: string, postId: string) {
  const post = await Post.findById(postId);
  if (!post) throw new HttpError(404, 'Post not found');
  const uid = new Types.ObjectId(userId);
  const existing = await PostSave.findOne({ postId: post._id, userId: uid });
  if (existing) {
    await existing.deleteOne();
    return { saved: false };
  }
  await PostSave.create({ postId: post._id, userId: uid });
  return { saved: true };
}

export async function listSaved(userId: string) {
  const uid = new Types.ObjectId(userId);
  const saves = await PostSave.find({ userId: uid }).sort({ createdAt: -1 });
  const postIds = saves.map((s) => s.postId);
  if (postIds.length === 0) return { items: [] };
  const posts = await Post.find({ _id: { $in: postIds } });
  const postMap = new Map(posts.map((p) => [p._id.toString(), p]));
  const authors = await buildAuthorMap(
    Array.from(new Set(posts.map((p) => p.authorId.toString())))
  );
  const likes = await PostLike.find({ postId: { $in: postIds }, userId: uid });
  const likedSet = new Set(likes.map((l) => l.postId.toString()));

  const items = saves
    .map((s) => postMap.get(s.postId.toString()))
    .filter((p): p is typeof posts[number] => !!p)
    .map((p) =>
      serializePost(p, authors.get(p.authorId.toString()), {
        liked: likedSet.has(p._id.toString()),
        saved: true,
      })
    );

  return { items };
}

export async function listComments(postId: string) {
  const comments = await Comment.find({ postId: new Types.ObjectId(postId) }).sort({
    createdAt: 1,
  });
  const authorIds = Array.from(new Set(comments.map((c) => c.authorId.toString())));
  const authors = await buildAuthorMap(authorIds);
  return comments.map((c) => ({
    id: c._id.toString(),
    postId: c.postId.toString(),
    text: c.text,
    createdAt: c.createdAt,
    author: authors.get(c.authorId.toString()) ?? {
      id: c.authorId.toString(),
      name: 'Unknown',
    },
  }));
}

export async function addComment(userId: string, postId: string, text: string) {
  const post = await Post.findById(postId);
  if (!post) throw new HttpError(404, 'Post not found');
  const comment = await Comment.create({
    postId: post._id,
    authorId: new Types.ObjectId(userId),
    text,
  });
  await Post.updateOne({ _id: post._id }, { $inc: { commentsCount: 1 } });
  const authors = await buildAuthorMap([userId]);
  return {
    id: comment._id.toString(),
    postId: post._id.toString(),
    text: comment.text,
    createdAt: comment.createdAt,
    author: authors.get(userId) ?? { id: userId, name: 'Unknown' },
  };
}

export async function deleteComment(userId: string, commentId: string) {
  const comment = await Comment.findById(commentId);
  if (!comment) throw new HttpError(404, 'Comment not found');
  if (comment.authorId.toString() !== userId) {
    throw new HttpError(403, 'Not your comment');
  }
  await comment.deleteOne();
  await Post.updateOne({ _id: comment.postId }, { $inc: { commentsCount: -1 } });
}
