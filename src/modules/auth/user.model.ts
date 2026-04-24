import { Schema, model, Document, Types } from 'mongoose';
import bcrypt from 'bcryptjs';

export type UserRole = 'member' | 'admin' | 'service_provider';

export interface UserDoc extends Document {
  _id: Types.ObjectId;
  name: string;
  email?: string;
  phone: string;
  passwordHash: string;
  role: UserRole;
  isPhoneVerified: boolean;
  isEmailVerified: boolean;
  avatarUrl?: string;
  gotra?: string;
  dob?: Date;
  gender?: 'male' | 'female' | 'other';
  city?: string;
  profileCompletion: number;
  roles: string[];
  createdAt: Date;
  updatedAt: Date;
  setPassword(plain: string): Promise<void>;
  comparePassword(plain: string): Promise<boolean>;
}

const UserSchema = new Schema<UserDoc>(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, lowercase: true, trim: true, sparse: true, unique: true },
    phone: { type: String, required: true, unique: true, trim: true },
    passwordHash: { type: String, required: true },
    role: {
      type: String,
      enum: ['member', 'admin', 'service_provider'],
      default: 'member',
    },
    isPhoneVerified: { type: Boolean, default: false },
    isEmailVerified: { type: Boolean, default: false },
    avatarUrl: String,
    gotra: String,
    dob: Date,
    gender: { type: String, enum: ['male', 'female', 'other'] },
    city: String,
    profileCompletion: { type: Number, default: 20 },
    roles: { type: [String], default: [] },
  },
  { timestamps: true }
);

UserSchema.methods.setPassword = async function (plain: string) {
  this.passwordHash = await bcrypt.hash(plain, 10);
};

UserSchema.methods.comparePassword = function (plain: string) {
  return bcrypt.compare(plain, this.passwordHash);
};

UserSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    delete r.passwordHash;
    return r;
  },
});

export const User = model<UserDoc>('User', UserSchema);
