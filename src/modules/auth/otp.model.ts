import { Schema, model, Document } from 'mongoose';

export type OtpPurpose = 'signup' | 'login' | 'reset_password' | 'verify_email';

export interface OtpDoc extends Document {
  phone?: string;
  email?: string;
  code: string;
  purpose: OtpPurpose;
  expiresAt: Date;
  consumedAt?: Date;
  attempts: number;
  createdAt: Date;
}

const OtpSchema = new Schema<OtpDoc>(
  {
    phone: { type: String, index: true },
    email: { type: String, index: true },
    code: { type: String, required: true },
    purpose: {
      type: String,
      enum: ['signup', 'login', 'reset_password', 'verify_email'],
      required: true,
    },
    expiresAt: { type: Date, required: true },
    consumedAt: Date,
    attempts: { type: Number, default: 0 },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

OtpSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const Otp = model<OtpDoc>('Otp', OtpSchema);
