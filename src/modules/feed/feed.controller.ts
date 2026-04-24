import { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { commentSchema, createPostSchema, listFeedQuerySchema } from './feed.schemas';
import * as svc from './feed.service';

export const listFeedHandler = asyncHandler(async (req: Request, res: Response) => {
  const q = listFeedQuerySchema.parse(req.query);
  const result = await svc.listFeed(req.user!.sub, q);
  res.json(result);
});

export const getPostHandler = asyncHandler(async (req: Request, res: Response) => {
  const post = await svc.getPost(req.user!.sub, String(req.params.id));
  res.json(post);
});

export const createPostHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = createPostSchema.parse(req.body);
  const post = await svc.createPost(req.user!.sub, data);
  res.status(201).json(post);
});

export const deletePostHandler = asyncHandler(async (req: Request, res: Response) => {
  await svc.deletePost(req.user!.sub, String(req.params.id));
  res.json({ ok: true });
});

export const toggleLikeHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.toggleLike(req.user!.sub, String(req.params.id));
  res.json(result);
});

export const toggleSaveHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.toggleSave(req.user!.sub, String(req.params.id));
  res.json(result);
});

export const listSavedHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.listSaved(req.user!.sub);
  res.json(result);
});

export const listCommentsHandler = asyncHandler(async (req: Request, res: Response) => {
  const comments = await svc.listComments(String(req.params.id));
  res.json({ items: comments });
});

export const addCommentHandler = asyncHandler(async (req: Request, res: Response) => {
  const { text } = commentSchema.parse(req.body);
  const comment = await svc.addComment(req.user!.sub, String(req.params.id), text);
  res.status(201).json(comment);
});

export const deleteCommentHandler = asyncHandler(async (req: Request, res: Response) => {
  await svc.deleteComment(req.user!.sub, String(req.params.commentId));
  res.json({ ok: true });
});
