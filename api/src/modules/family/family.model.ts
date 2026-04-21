import { Schema, model, Document, Types } from 'mongoose';

export const RELATIONS = [
  'father',
  'mother',
  'brother',
  'sister',
  'son',
  'daughter',
  'spouse',
  'uncle',
  'aunt',
  'cousin',
  'grandfather',
  'grandmother',
  'other',
] as const;

export type Relation = (typeof RELATIONS)[number];

export const INVERSE_RELATION: Record<Relation, Relation> = {
  father: 'son',
  mother: 'son',
  brother: 'brother',
  sister: 'sister',
  son: 'father',
  daughter: 'father',
  spouse: 'spouse',
  uncle: 'cousin',
  aunt: 'cousin',
  cousin: 'cousin',
  grandfather: 'son',
  grandmother: 'son',
  other: 'other',
};

/** Accepted edges: both sides of the relationship get one row each. */
export interface FamilyMemberDoc extends Document {
  _id: Types.ObjectId;
  ownerId: Types.ObjectId; // the user whose tree this row belongs to
  relativeUserId?: Types.ObjectId; // set when relative is a registered user
  relation: Relation;
  displayName: string;
  displayAvatar?: string;
  phone?: string;
  email?: string;
  createdAt: Date;
  updatedAt: Date;
}

const FamilyMemberSchema = new Schema<FamilyMemberDoc>(
  {
    ownerId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    relativeUserId: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    relation: { type: String, enum: RELATIONS, required: true },
    displayName: { type: String, required: true },
    displayAvatar: String,
    phone: String,
    email: String,
  },
  { timestamps: true }
);

FamilyMemberSchema.index({ ownerId: 1, relativeUserId: 1 }, { unique: true, sparse: true });

FamilyMemberSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const FamilyMember = model<FamilyMemberDoc>('FamilyMember', FamilyMemberSchema);

export type InvitationStatus = 'pending' | 'accepted' | 'rejected' | 'cancelled';
export type InvitationChannel = 'in_app' | 'external';

export interface InvitationDoc extends Document {
  _id: Types.ObjectId;
  senderId: Types.ObjectId;
  receiverUserId?: Types.ObjectId; // set if recipient is a registered user at time of send
  relation: Relation; // relation from sender → receiver (sender says: "you are my brother")
  proposedName: string;
  phone?: string;
  email?: string;
  channel: InvitationChannel;
  status: InvitationStatus;
  createdAt: Date;
  updatedAt: Date;
}

const InvitationSchema = new Schema<InvitationDoc>(
  {
    senderId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    receiverUserId: { type: Schema.Types.ObjectId, ref: 'User', index: true },
    relation: { type: String, enum: RELATIONS, required: true },
    proposedName: { type: String, required: true },
    phone: { type: String, index: true },
    email: { type: String, index: true },
    channel: { type: String, enum: ['in_app', 'external'], default: 'in_app' },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'rejected', 'cancelled'],
      default: 'pending',
      index: true,
    },
  },
  { timestamps: true }
);

InvitationSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const Invitation = model<InvitationDoc>('Invitation', InvitationSchema);
