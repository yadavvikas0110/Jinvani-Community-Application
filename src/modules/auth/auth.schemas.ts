import { z } from 'zod';

const phone = z.string().regex(/^\+?\d{10,15}$/, 'Invalid phone');
const email = z.string().email();
const password = z
  .string()
  .min(8, 'At least 8 characters')
  .regex(/\d/, 'Must contain a number');

export const signupStartSchema = z.object({
  name: z.string().min(2).max(80),
  phone,
  email: email.optional(),
});

export const signupVerifyOtpSchema = z.object({
  phone,
  code: z.string().length(6),
});

export const signupCompleteSchema = z.object({
  signupToken: z.string().min(10),
  password,
  roles: z.array(z.string()).optional(),
});

export const loginSchema = z.object({
  identifier: z.string().min(3),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(10),
});

export const forgotPasswordSchema = z.object({ phone });

export const forgotVerifyOtpSchema = z.object({
  phone,
  code: z.string().length(6),
});

export const resetPasswordSchema = z.object({
  resetToken: z.string().min(10),
  newPassword: password,
});

export const updateRolesSchema = z.object({
  roles: z.array(z.string().min(2)).min(1),
});

export const verifyEmailStartSchema = z.object({ email });
export const verifyEmailCompleteSchema = z.object({ email, code: z.string().length(6) });

export const googleLoginSchema = z.object({ idToken: z.string().min(10) });
