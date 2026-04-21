import { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import {
  signupStartSchema,
  signupVerifyOtpSchema,
  signupCompleteSchema,
  loginSchema,
  refreshSchema,
  forgotPasswordSchema,
  forgotVerifyOtpSchema,
  resetPasswordSchema,
  updateRolesSchema,
} from './auth.schemas';
import * as svc from './auth.service';
import { User } from './user.model';

export const signupStartHandler = asyncHandler(async (req: Request, res: Response) => {
  const input = signupStartSchema.parse(req.body);
  const result = await svc.signupStart(input);
  res.status(201).json(result);
});

export const signupVerifyOtpHandler = asyncHandler(async (req: Request, res: Response) => {
  const { phone, code } = signupVerifyOtpSchema.parse(req.body);
  const result = await svc.signupVerifyOtp(phone, code);
  res.json(result);
});

export const signupCompleteHandler = asyncHandler(async (req: Request, res: Response) => {
  const { signupToken, password, roles } = signupCompleteSchema.parse(req.body);
  const result = await svc.signupComplete(signupToken, password, roles);
  res.json(result);
});

export const resendOtpHandler = asyncHandler(async (req: Request, res: Response) => {
  const { phone } = signupVerifyOtpSchema.pick({ phone: true }).parse(req.body);
  const result = await svc.resendSignupOtp(phone);
  res.json(result);
});

export const loginHandler = asyncHandler(async (req: Request, res: Response) => {
  const { identifier, password } = loginSchema.parse(req.body);
  const result = await svc.login(identifier, password);
  res.json(result);
});

export const refreshHandler = asyncHandler(async (req: Request, res: Response) => {
  const { refreshToken } = refreshSchema.parse(req.body);
  const tokens = await svc.refresh(refreshToken);
  res.json(tokens);
});

export const forgotPasswordHandler = asyncHandler(async (req: Request, res: Response) => {
  const { phone } = forgotPasswordSchema.parse(req.body);
  const result = await svc.forgotPassword(phone);
  res.json(result);
});

export const forgotVerifyOtpHandler = asyncHandler(async (req: Request, res: Response) => {
  const { phone, code } = forgotVerifyOtpSchema.parse(req.body);
  const result = await svc.forgotPasswordVerifyOtp(phone, code);
  res.json(result);
});

export const forgotResendOtpHandler = asyncHandler(async (req: Request, res: Response) => {
  const { phone } = forgotPasswordSchema.parse(req.body);
  const result = await svc.resendResetOtp(phone);
  res.json(result);
});

export const resetPasswordHandler = asyncHandler(async (req: Request, res: Response) => {
  const { resetToken, newPassword } = resetPasswordSchema.parse(req.body);
  const result = await svc.resetPassword(resetToken, newPassword);
  res.json(result);
});

export const updateRolesHandler = asyncHandler(async (req: Request, res: Response) => {
  const { roles } = updateRolesSchema.parse(req.body);
  const user = await svc.updateRoles(req.user!.sub, roles);
  res.json({ user });
});

export const meHandler = asyncHandler(async (req: Request, res: Response) => {
  const user = await User.findById(req.user!.sub);
  res.json({ user: user?.toJSON() });
});
