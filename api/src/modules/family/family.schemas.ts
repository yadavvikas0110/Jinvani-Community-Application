import { z } from 'zod';
import { RELATIONS } from './family.model';

export const inviteSchema = z
  .object({
    name: z.string().min(2).max(80),
    relation: z.enum(RELATIONS),
    phone: z.string().trim().optional(),
    email: z.string().email().optional(),
  })
  .refine((v) => (v.phone && v.phone.length > 0) || (v.email && v.email.length > 0), {
    message: 'Provide at least a phone or an email',
    path: ['phone'],
  });

export const externalInviteSchema = z
  .object({
    phone: z.string().trim().optional(),
    email: z.string().email().optional(),
  })
  .refine((v) => (v.phone && v.phone.length > 0) || (v.email && v.email.length > 0), {
    message: 'Provide at least a phone or an email',
    path: ['phone'],
  });
