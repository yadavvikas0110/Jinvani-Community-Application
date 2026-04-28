import { Schema, model, Document, Types } from 'mongoose';

export type TicketStatus = 'open' | 'in_progress' | 'resolved' | 'closed';

export interface SupportTicketDoc extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  ref: string;
  subject: string;
  description: string;
  status: TicketStatus;
  createdAt: Date;
  updatedAt: Date;
}

const SupportTicketSchema = new Schema<SupportTicketDoc>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    ref: { type: String, required: true, unique: true, index: true },
    subject: { type: String, required: true, maxlength: 120 },
    description: { type: String, required: true, maxlength: 500 },
    status: {
      type: String,
      enum: ['open', 'in_progress', 'resolved', 'closed'],
      default: 'open',
    },
  },
  { timestamps: true }
);

SupportTicketSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const SupportTicket = model<SupportTicketDoc>('SupportTicket', SupportTicketSchema);

export interface FeedbackDoc extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  subject: string;
  description: string;
  createdAt: Date;
  updatedAt: Date;
}

const FeedbackSchema = new Schema<FeedbackDoc>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    subject: { type: String, required: true, maxlength: 120 },
    description: { type: String, required: true, maxlength: 500 },
  },
  { timestamps: true }
);

FeedbackSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const Feedback = model<FeedbackDoc>('Feedback', FeedbackSchema);
