import { Schema, model, Document } from 'mongoose';

export interface SignupDraftDoc extends Document {
  phone: string;
  email?: string;
  name: string;
  verifiedAt?: Date;
  expiresAt: Date;
  createdAt: Date;
}

const SignupDraftSchema = new Schema<SignupDraftDoc>(
  {
    phone: { type: String, required: true, index: true },
    email: String,
    name: { type: String, required: true },
    verifiedAt: Date,
    expiresAt: { type: Date, required: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

SignupDraftSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const SignupDraft = model<SignupDraftDoc>('SignupDraft', SignupDraftSchema);
