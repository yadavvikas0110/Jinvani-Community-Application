import { Schema, model, Document, Types } from 'mongoose';

export type PostType = 'post' | 'blog';

export interface PostDoc extends Document {
  _id: Types.ObjectId;
  authorId: Types.ObjectId;
  type: PostType;
  title?: string;
  body: string;
  imageUrl?: string;
  likesCount: number;
  commentsCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const PostSchema = new Schema<PostDoc>(
  {
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    type: { type: String, enum: ['post', 'blog'], required: true, index: true },
    title: { type: String, trim: true, maxlength: 200 },
    body: { type: String, required: true, trim: true, maxlength: 5000 },
    imageUrl: String,
    likesCount: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

PostSchema.index({ type: 1, createdAt: -1 });

PostSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const Post = model<PostDoc>('Post', PostSchema);

export interface PostLikeDoc extends Document {
  _id: Types.ObjectId;
  postId: Types.ObjectId;
  userId: Types.ObjectId;
  createdAt: Date;
}

const PostLikeSchema = new Schema<PostLikeDoc>(
  {
    postId: { type: Schema.Types.ObjectId, ref: 'Post', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

PostLikeSchema.index({ postId: 1, userId: 1 }, { unique: true });

export const PostLike = model<PostLikeDoc>('PostLike', PostLikeSchema);

export interface PostSaveDoc extends Document {
  _id: Types.ObjectId;
  postId: Types.ObjectId;
  userId: Types.ObjectId;
  createdAt: Date;
}

const PostSaveSchema = new Schema<PostSaveDoc>(
  {
    postId: { type: Schema.Types.ObjectId, ref: 'Post', required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

PostSaveSchema.index({ postId: 1, userId: 1 }, { unique: true });

export const PostSave = model<PostSaveDoc>('PostSave', PostSaveSchema);

export interface CommentDoc extends Document {
  _id: Types.ObjectId;
  postId: Types.ObjectId;
  authorId: Types.ObjectId;
  text: string;
  createdAt: Date;
  updatedAt: Date;
}

const CommentSchema = new Schema<CommentDoc>(
  {
    postId: { type: Schema.Types.ObjectId, ref: 'Post', required: true, index: true },
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    text: { type: String, required: true, trim: true, maxlength: 1000 },
  },
  { timestamps: true }
);

CommentSchema.index({ postId: 1, createdAt: -1 });

CommentSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const Comment = model<CommentDoc>('Comment', CommentSchema);
