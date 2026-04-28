import { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler';
import * as svc from './support.service';
import { createTicketSchema, submitFeedbackSchema } from './support.schemas';

export const postTicketHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = createTicketSchema.parse(req.body);
  const ticket = await svc.createTicket(req.user!.sub, data);
  res.status(201).json({ ticket: ticket.toJSON() });
});

export const getMyTicketsHandler = asyncHandler(async (req: Request, res: Response) => {
  const tickets = await svc.listMyTickets(req.user!.sub);
  res.json({ tickets: tickets.map((t) => t.toJSON()) });
});

export const postFeedbackHandler = asyncHandler(async (req: Request, res: Response) => {
  const data = submitFeedbackSchema.parse(req.body);
  const feedback = await svc.submitFeedback(req.user!.sub, data);
  res.status(201).json({ feedback: feedback.toJSON() });
});
