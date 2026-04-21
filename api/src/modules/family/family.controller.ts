import { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import { externalInviteSchema, inviteSchema } from './family.schemas';
import * as svc from './family.service';

export const getFamilyHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.getFamily(req.user!.sub);
  res.json(result);
});

export const inviteHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = inviteSchema.parse(req.body);
  const result = await svc.createInvitation(req.user!.sub, data);
  res.status(201).json(result);
});

export const externalInviteHandler = asyncHandler(async (req: Request, res: Response) => {
  // Sender confirmed to invite an unregistered user — body reuses the fields.
  const data = inviteSchema.merge(externalInviteSchema).parse(req.body);
  const result = await svc.sendExternalInvite(req.user!.sub, data);
  res.status(201).json(result);
});

export const acceptHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.acceptInvitation(req.user!.sub, String(req.params.id));
  res.json({ invitation: result });
});

export const rejectHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.rejectInvitation(req.user!.sub, String(req.params.id));
  res.json({ invitation: result });
});

export const cancelHandler = asyncHandler(async (req: Request, res: Response) => {
  const result = await svc.cancelInvitation(req.user!.sub, String(req.params.id));
  res.json({ invitation: result });
});

export const removeMemberHandler = asyncHandler(async (req: Request, res: Response) => {
  await svc.removeMember(req.user!.sub, String(req.params.id));
  res.json({ ok: true });
});
