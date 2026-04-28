import { z } from 'zod';

export const createTicketSchema = z.object({
  subject: z.string().min(1).max(120),
  description: z.string().min(1).max(500),
});

export const submitFeedbackSchema = z.object({
  subject: z.string().min(1).max(120),
  description: z.string().min(1).max(500),
});
