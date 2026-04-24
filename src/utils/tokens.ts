import jwt, { SignOptions } from 'jsonwebtoken';
import { env } from '../config/env';

export function signAccess(payload: object) {
  return jwt.sign(payload, env.JWT_ACCESS_SECRET, {
    expiresIn: env.JWT_ACCESS_TTL as SignOptions['expiresIn'],
  });
}

export function signRefresh(payload: object) {
  return jwt.sign(payload, env.JWT_REFRESH_SECRET, {
    expiresIn: env.JWT_REFRESH_TTL as SignOptions['expiresIn'],
  });
}

export function verifyRefresh<T = unknown>(token: string): T {
  return jwt.verify(token, env.JWT_REFRESH_SECRET) as T;
}
