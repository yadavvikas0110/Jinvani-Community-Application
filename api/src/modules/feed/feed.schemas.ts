import { z } from 'zod';

export const createPostSchema = z
  .object({
    type: z.enum(['post', 'blog']),
    title: z.string().trim().max(200).optional(),
    body: z.string().trim().min(1).max(5000),
    imageUrl: z.string().trim().max(500).optional(),
  })
  .refine((v) => v.type !== 'blog' || (v.title && v.title.length >= 3), {
    message: 'Blog posts require a title of at least 3 characters',
    path: ['title'],
  })
  .refine((v) => v.type !== 'blog' || (v.imageUrl && v.imageUrl.length > 0), {
    message: 'Blog posts require a cover image',
    path: ['imageUrl'],
  });

export const listFeedQuerySchema = z.object({
  type: z.enum(['post', 'blog']).optional(),
  cursor: z.string().trim().optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export const commentSchema = z.object({
  text: z.string().trim().min(1).max(1000),
});
