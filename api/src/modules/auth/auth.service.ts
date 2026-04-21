import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../../config/env';
import { HttpError } from '../../middleware/error';
import { linkExternalInvitations } from '../family/family.service';
import { signAccess, signRefresh, verifyRefresh } from '../../utils/tokens';
import { Otp, OtpPurpose } from './otp.model';
import { SignupDraft } from './signupDraft.model';
import { User, UserDoc } from './user.model';

const OTP_TTL_MIN = 10;
const SIGNUP_TOKEN_TTL = '15m';
const RESET_TOKEN_TTL = '15m';
const DRAFT_TTL_MIN = 30;

function genOtp() {
  if (env.NODE_ENV !== 'production') return env.OTP_DEV_CODE;
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

async function issueOtp(phone: string, purpose: OtpPurpose) {
  const code = genOtp();
  const expiresAt = new Date(Date.now() + OTP_TTL_MIN * 60 * 1000);
  await Otp.create({ phone, code, purpose, expiresAt });
  // TODO integrate SMS provider; dev returns code
  return {
    expiresInSec: OTP_TTL_MIN * 60,
    devCode: env.NODE_ENV !== 'production' ? code : undefined,
  };
}

async function consumeOtp(phone: string, code: string, purpose: OtpPurpose) {
  const otp = await Otp.findOne({ phone, purpose, consumedAt: { $exists: false } }).sort({ createdAt: -1 });
  if (!otp) throw new HttpError(400, 'No active OTP');
  if (otp.expiresAt.getTime() < Date.now()) throw new HttpError(400, 'OTP expired');
  if (otp.attempts >= 5) throw new HttpError(429, 'Too many attempts');
  if (otp.code !== code) {
    otp.attempts += 1;
    await otp.save();
    throw new HttpError(400, 'Invalid OTP');
  }
  otp.consumedAt = new Date();
  await otp.save();
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
  return issueOtp(input.phone, 'signup');
}

export async function signupVerifyOtp(phone: string, code: string) {
  const draft = await SignupDraft.findOne({ phone });
  if (!draft) throw new HttpError(404, 'Signup draft not found or expired');
  await consumeOtp(phone, code, 'signup');
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
  return issueOtp(phone, 'signup');
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
  return issueOtp(phone, 'reset_password');
}

export async function forgotPasswordVerifyOtp(phone: string, code: string) {
  const user = await User.findOne({ phone });
  if (!user) throw new HttpError(404, 'User not found');
  await consumeOtp(phone, code, 'reset_password');
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
  return issueOtp(phone, 'reset_password');
}

export async function updateRoles(userId: string, roles: string[]) {
  const user = await User.findByIdAndUpdate(userId, { $set: { roles } }, { new: true });
  if (!user) throw new HttpError(404, 'User not found');
  return user.toJSON();
}
