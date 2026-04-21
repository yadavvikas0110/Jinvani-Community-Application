import { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import * as svc from './profile.service';
import {
  personalDetailsSchema,
  addEducationSchema,
  updateEducationSchema,
  workDetailsSchema,
  economicDataSchema,
  bioSchema,
  goalsSchema,
} from './profile.schemas';

export const getProfileHandler = asyncHandler(async (req: Request, res: Response) => {
  const profile = await svc.getProfile(req.user!.sub);
  res.json({ profile: profile.toJSON() });
});

export const putPersonalHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = personalDetailsSchema.parse(req.body);
  const profile = await svc.updatePersonal(req.user!.sub, data);
  res.json({ profile: profile.toJSON() });
});

export const postEducationHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = addEducationSchema.parse(req.body);
  const profile = await svc.addEducation(req.user!.sub, data);
  res.status(201).json({ profile: profile.toJSON() });
});

export const putEducationHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = updateEducationSchema.parse(req.body);
  const profile = await svc.updateEducation(req.user!.sub, String(req.params.id), data);
  res.json({ profile: profile.toJSON() });
});

export const deleteEducationHandler = asyncHandler(async (req: Request, res: Response) => {
  const profile = await svc.removeEducation(req.user!.sub, String(req.params.id));
  res.json({ profile: profile.toJSON() });
});

export const putWorkHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = workDetailsSchema.parse(req.body);
  const profile = await svc.updateWork(req.user!.sub, data);
  res.json({ profile: profile.toJSON() });
});

export const putEconomicHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = economicDataSchema.parse(req.body);
  const profile = await svc.updateEconomic(req.user!.sub, data);
  res.json({ profile: profile.toJSON() });
});

export const putBioHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = bioSchema.parse(req.body);
  const profile = await svc.updateBio(req.user!.sub, data);
  res.json({ profile: profile.toJSON() });
});

export const putGoalsHandler = asyncHandler(async (req: Request, res: Response) => {
  const { goals } = goalsSchema.parse(req.body);
  const profile = await svc.updateGoals(req.user!.sub, goals);
  res.json({ profile: profile.toJSON() });
});
