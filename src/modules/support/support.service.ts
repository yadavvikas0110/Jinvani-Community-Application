import { Types } from 'mongoose';
import { SupportTicket, Feedback, SupportTicketDoc, FeedbackDoc } from './support.model';

function generateTicketRef(): string {
  const ts = Date.now().toString(36).toUpperCase();
  const rand = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `TKT-${ts}-${rand}`;
}

export async function createTicket(
  userId: string,
  data: { subject: string; description: string }
): Promise<SupportTicketDoc> {
  const ticket = await SupportTicket.create({
    userId: new Types.ObjectId(userId),
    ref: generateTicketRef(),
    subject: data.subject.trim(),
    description: data.description.trim(),
    status: 'open',
  });
  return ticket;
}

export async function listMyTickets(userId: string): Promise<SupportTicketDoc[]> {
  return SupportTicket.find({ userId: new Types.ObjectId(userId) })
    .sort({ createdAt: -1 })
    .limit(100);
}

export async function submitFeedback(
  userId: string,
  data: { subject: string; description: string }
): Promise<FeedbackDoc> {
  const fb = await Feedback.create({
    userId: new Types.ObjectId(userId),
    subject: data.subject.trim(),
    description: data.description.trim(),
  });
  return fb;
}
