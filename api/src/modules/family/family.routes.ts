import { Router } from 'express';
import { requireAuth } from '../../middleware/auth';
import {
  acceptHandler,
  cancelHandler,
  externalInviteHandler,
  getFamilyHandler,
  inviteHandler,
  rejectHandler,
  removeMemberHandler,
} from './family.controller';

export const familyRouter = Router();

familyRouter.use(requireAuth);

familyRouter.get('/', getFamilyHandler);
familyRouter.post('/invite', inviteHandler);
familyRouter.post('/invite/external', externalInviteHandler);
familyRouter.post('/requests/:id/accept', acceptHandler);
familyRouter.post('/requests/:id/reject', rejectHandler);
familyRouter.post('/requests/:id/cancel', cancelHandler);
familyRouter.delete('/members/:id', removeMemberHandler);
