import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../../config/env';
import { HttpError } from '../../middleware/error';
import { linkExternalInvitations } from '../family/family.service';
import { signAccess, signRefresh, verifyRefresh } from '../../utils/tokens';
import { Otp, OtpPurpose } from './otp.model';
import { SignupDraft } from './signupDraft.model';
import { User, UserDoc } from './user.model';

const OTP_TTL_MIN = 5;
const SIGNUP_TOKEN_TTL = '15m';
const RESET_TOKEN_TTL = '15m';
const DRAFT_TTL_MIN = 30;

function genOtp() {
  if (env.NODE_ENV !== 'production') return env.OTP_DEV_CODE;
  // Use a slightly more secure random for production
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function buildTokens(user: UserDoc) {
  const id = user._id.toString();
  const accessToken = signAccess({ sub: id, role: user.role });
  const refreshToken = signRefresh({ sub: id, type: 'refresh' });
  return { accessToken, refreshToken };
}

function signSignupToken(phone: string) {
  return jwt.sign({ phone, typ: 'signup' }, env.JWT_ACCESS_SECRET, {
    expiresIn: SIGNUP_TOKEN_TTL as SignOptions['expiresIn'],
  });
}

function verifySignupToken(token: string): { phone: string } {
  const payload = jwt.verify(token, env.JWT_ACCESS_SECRET) as { phone: string; typ: string };
  if (payload.typ !== 'signup') throw new HttpError(401, 'Invalid signup token');
  return { phone: payload.phone };
}

function signResetToken(phone: string) {
  return jwt.sign({ phone, typ: 'reset' }, env.JWT_ACCESS_SECRET, {
    expiresIn: RESET_TOKEN_TTL as SignOptions['expiresIn'],
  });
}

function verifyResetToken(token: string): { phone: string } {
  const payload = jwt.verify(token, env.JWT_ACCESS_SECRET) as { phone: string; typ: string };
  if (payload.typ !== 'reset') throw new HttpError(401, 'Invalid reset token');
  return { phone: payload.phone };
}

import { sendOtpEmail } from '../../utils/mail';

async function issueOtp(identifier: { phone?: string; email?: string }, purpose: OtpPurpose) {
  const code = genOtp();
  const expiresAt = new Date(Date.now() + OTP_TTL_MIN * 60 * 1000);
  
  // 1. Cleanup: Overwrite/Delete old active OTPs for this user/purpose
  const query = identifier.phone ? { phone: identifier.phone, purpose } : { email: identifier.email, purpose };
  await Otp.deleteMany(query);

  // 2. Create new OTP
  await Otp.create({ ...identifier, code, purpose, expiresAt });
  
  // 3. Delivery
  if (identifier.email) {
    await sendOtpEmail(identifier.email, code).catch(err => {
       console.error('[auth] Email dispatch failure (non-blocking for DB record):', err);
    });
  }

  if (identifier.phone && env.SMS_DOMAIN && env.SMS_USERNAME) {
    try {
      const tPhone = identifier.phone.replace('+', '');
      const messageText = `[Jinvani Community] Your secure OTP is: ${code}. Do not share this with anyone.`;
      const message = encodeURIComponent(messageText);
      const url = `https://${env.SMS_DOMAIN}/fe/api/v1/send?username=${env.SMS_USERNAME}&password=${env.SMS_PASSWORD}&unicode=false&from=${env.SMS_SENDER}&to=${tPhone}&text=${message}&dltContentId=${env.SMS_DLT_ID}`;
      
      console.log(`[sms] Triggering dispatch to ${tPhone}`);
      const response = await fetch(url);
      if (!response.ok) {
        console.error(`[sms] Failed to send. Gateway status: ${response.status}`);
      }
    } catch (err) {
      console.error('[sms] Fetch request failed:', err);
    }
  }

  return {
    expiresInSec: OTP_TTL_MIN * 60,
    devCode: env.NODE_ENV !== 'production' ? code : undefined,
  };
}

async function consumeOtp(identifier: { phone?: string; email?: string }, code: string, purpose: OtpPurpose) {
  const query = identifier.phone 
    ? { phone: identifier.phone, purpose, consumedAt: { $exists: false } }
    : { email: identifier.email, purpose, consumedAt: { $exists: false } };

  const otp = await Otp.findOne(query).sort({ createdAt: -1 });
  
  if (!otp) throw new HttpError(400, 'No active OTP found');
  if (otp.expiresAt.getTime() < Date.now()) {
    await otp.deleteOne(); // Optional cleanup
    throw new HttpError(400, 'OTP has expired');
  }
  if (otp.attempts >= 5) {
    await otp.deleteOne();
    throw new HttpError(429, 'Too many invalid attempts. Please request a new code.');
  }

  if (otp.code !== code) {
    otp.attempts += 1;
    await otp.save();
    throw new HttpError(400, 'Invalid verification code');
  }

  // Delete the record immediately after success to prevent reuse
  await otp.deleteOne();
}

export async function signupStart(input: { name: string; phone: string; email?: string }) {
  const existing = await User.findOne({ phone: input.phone });
  if (existing) throw new HttpError(409, 'Phone already registered');
  await SignupDraft.deleteMany({ phone: input.phone });
  await SignupDraft.create({
    phone: input.phone,
    email: input.email,
    name: input.name,
    expiresAt: new Date(Date.now() + DRAFT_TTL_MIN * 60 * 1000),
  });
  return issueOtp({ phone: input.phone }, 'signup');
}

export async function signupVerifyOtp(phone: string, code: string) {
  const draft = await SignupDraft.findOne({ phone });
  if (!draft) throw new HttpError(404, 'Signup draft not found or expired');
  await consumeOtp({ phone }, code, 'signup');
  draft.verifiedAt = new Date();
  await draft.save();
  return { signupToken: signSignupToken(phone) };
}

export async function signupComplete(signupToken: string, password: string, roles?: string[]) {
  const { phone } = verifySignupToken(signupToken);
  const draft = await SignupDraft.findOne({ phone });
  if (!draft || !draft.verifiedAt) throw new HttpError(400, 'OTP not verified');
  const exists = await User.findOne({ phone });
  if (exists) throw new HttpError(409, 'Phone already registered');
  const user = new User({
    name: draft.name,
    phone: draft.phone,
    email: draft.email,
    role: 'member',
    isPhoneVerified: true,
    roles: roles ?? [],
  });
  await user.setPassword(password);
  await user.save();
  await SignupDraft.deleteMany({ phone });
  await linkExternalInvitations({
    id: user._id.toString(),
    phone: user.phone,
    email: user.email,
  });
  const tokens = buildTokens(user);
  return { user: user.toJSON(), ...tokens };
}

export async function resendSignupOtp(phone: string) {
  const draft = await SignupDraft.findOne({ phone });
  if (!draft) throw new HttpError(404, 'Signup draft not found');
  return issueOtp({ phone }, 'signup');
}

export async function login(identifier: string, password: string) {
  const query = identifier.includes('@') ? { email: identifier.toLowerCase() } : { phone: identifier };
  const user = await User.findOne(query);
  if (!user) throw new HttpError(401, 'Invalid credentials');
  const ok = await user.comparePassword(password);
  if (!ok) throw new HttpError(401, 'Invalid credentials');
  if (!user.isPhoneVerified) throw new HttpError(403, 'Phone not verified');
  const tokens = buildTokens(user);
  return { user: user.toJSON(), ...tokens };
}

export async function refresh(refreshToken: string) {
  let payload: { sub: string };
  try {
    payload = verifyRefresh<{ sub: string }>(refreshToken);
  } catch {
    throw new HttpError(401, 'Invalid refresh token');
  }
  const user = await User.findById(payload.sub);
  if (!user) throw new HttpError(401, 'User not found');
  return buildTokens(user);
}

export async function forgotPassword(phone: string) {
  const user = await User.findOne({ phone });
  if (!user) throw new HttpError(404, 'User not found');
  return issueOtp({ phone }, 'reset_password');
}

export async function forgotPasswordVerifyOtp(phone: string, code: string) {
  const user = await User.findOne({ phone });
  if (!user) throw new HttpError(404, 'User not found');
  await consumeOtp({ phone }, code, 'reset_password');
  return { resetToken: signResetToken(phone) };
}

export async function resetPassword(resetToken: string, newPassword: string) {
  const { phone } = verifyResetToken(resetToken);
  const user = await User.findOne({ phone });
  if (!user) throw new HttpError(404, 'User not found');
  await user.setPassword(newPassword);
  await user.save();
  return { ok: true };
}

export async function resendResetOtp(phone: string) {
  const user = await User.findOne({ phone });
  if (!user) throw new HttpError(404, 'User not found');
  return issueOtp({ phone }, 'reset_password');
}

export async function startEmailVerification(userId: string, email: string) {
  // Check if email already verified or used by another
  const existing = await User.findOne({ email: email.toLowerCase() });
  if (existing && existing._id.toString() !== userId) {
    throw new HttpError(409, 'Email already in use by another account');
  }
  return issueOtp({ email: email.toLowerCase() }, 'verify_email');
}

export async function completeEmailVerification(userId: string, email: string, code: string) {
  await consumeOtp({ email: email.toLowerCase() }, code, 'verify_email');
  const user = await User.findByIdAndUpdate(userId, { $set: { email: email.toLowerCase(), isEmailVerified: true } }, { new: true });
  if (!user) throw new HttpError(404, 'User not found');
  return user.toJSON();
}

export async function updateRoles(userId: string, roles: string[]) {
  const user = await User.findByIdAndUpdate(userId, { $set: { roles } }, { new: true });
  if (!user) throw new HttpError(404, 'User not found');
  return user.toJSON();
}
