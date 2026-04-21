import { Router } from 'express';
import { requireAuth } from '../../middleware/auth';
import {
  signupStartHandler,
  signupVerifyOtpHandler,
  signupCompleteHandler,
  resendOtpHandler,
  loginHandler,
  refreshHandler,
  forgotPasswordHandler,
  forgotVerifyOtpHandler,
  forgotResendOtpHandler,
  resetPasswordHandler,
  updateRolesHandler,
  meHandler,
} from './auth.controller';

export const authRouter = Router();

// Signup (3-step)
authRouter.post('/signup/start', signupStartHandler);
authRouter.post('/signup/verify-otp', signupVerifyOtpHandler);
authRouter.post('/signup/complete', signupCompleteHandler);
authRouter.post('/signup/resend-otp', resendOtpHandler);

// Session
authRouter.post('/login', loginHandler);
authRouter.post('/refresh', refreshHandler);

// Password reset (3-step)
authRouter.post('/forgot-password', forgotPasswordHandler);
authRouter.post('/forgot-password/verify-otp', forgotVerifyOtpHandler);
authRouter.post('/forgot-password/resend-otp', forgotResendOtpHandler);
authRouter.post('/reset-password', resetPasswordHandler);

// Authenticated
authRouter.get('/me', requireAuth, meHandler);
authRouter.put('/me/roles', requireAuth, updateRolesHandler);
