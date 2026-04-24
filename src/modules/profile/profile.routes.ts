import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import crypto from 'crypto';
import { requireAuth } from '../../middleware/auth';
import { asyncHandler } from '../../utils/asyncHandler';
import {
  getProfileHandler,
  putPersonalHandler,
  postEducationHandler,
  putEducationHandler,
  deleteEducationHandler,
  putWorkHandler,
  putEconomicHandler,
  putBioHandler,
  putGoalsHandler,
} from './profile.controller';

const UPLOAD_DIR = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${crypto.randomBytes(12).toString('hex')}${ext}`);
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ok = ['image/jpeg', 'image/png', 'application/pdf'].includes(file.mimetype);
    if (ok) cb(null, true);
    else cb(null, false);
  },
});

export const profileRouter = Router();

profileRouter.use(requireAuth);

profileRouter.get('/', getProfileHandler);
profileRouter.put('/personal', putPersonalHandler);

profileRouter.post('/education', postEducationHandler);
profileRouter.put('/education/:id', putEducationHandler);
profileRouter.delete('/education/:id', deleteEducationHandler);

profileRouter.put('/work', putWorkHandler);
profileRouter.put('/economic', putEconomicHandler);
profileRouter.put('/bio', putBioHandler);
profileRouter.put('/goals', putGoalsHandler);

profileRouter.post(
  '/upload',
  upload.single('file'),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.file) return res.status(400).json({ error: { message: 'No file uploaded' } });
    const url = `/static/uploads/${req.file.filename}`;
    res.status(201).json({ url, filename: req.file.filename, size: req.file.size });
  })
);
