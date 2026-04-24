import path from 'path';
import os from 'os';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler, notFound } from './middleware/error';
import { authRouter } from './modules/auth/auth.routes';
import { familyRouter } from './modules/family/family.routes';
import { feedRouter } from './modules/feed/feed.routes';
import { profileRouter } from './modules/profile/profile.routes';

export function createApp() {
  const app = express();

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(cors());
  app.use(express.json({ limit: '1mb' }));
  app.use(morgan('dev'));

  app.get('/health', (_req, res) => res.json({ ok: true }));

  app.use('/api/v1/auth', authRouter);
  app.use('/api/v1/users/me/profile', profileRouter);
  app.use('/api/v1/users/me/family', familyRouter);
  app.use('/api/v1/feed', feedRouter);

  app.use('/static/uploads', express.static(path.join(os.tmpdir(), 'uploads')));

  app.use(notFound);
  app.use(errorHandler);

  return app;
}
