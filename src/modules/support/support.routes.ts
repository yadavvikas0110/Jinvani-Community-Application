import { Router } from 'express';
import { requireAuth } from '../../middleware/auth';
import {
  postTicketHandler,
  getMyTicketsHandler,
  postFeedbackHandler,
} from './support.controller';

export const supportRouter = Router();

supportRouter.use(requireAuth);

supportRouter.post('/tickets', postTicketHandler);
supportRouter.get('/tickets', getMyTicketsHandler);
supportRouter.post('/feedback', postFeedbackHandler);
