import { Types } from 'mongoose';
import { HttpError } from '../../middleware/error';
import { User } from '../auth/user.model';
import { recomputeCompletion } from '../profile/profile.service';
import {
  FamilyMember,
  Invitation,
  INVERSE_RELATION,
  Relation,
} from './family.model';

function normalizePhone(phone?: string | null): string | undefined {
  if (!phone) return undefined;
  const t = phone.trim();
  if (!t) return undefined;
  return t.startsWith('+') ? t : `+91${t.replace(/\D/g, '')}`;
}

function normalizeEmail(email?: string | null): string | undefined {
  const t = email?.trim().toLowerCase();
  return t && t.length > 0 ? t : undefined;
}

async function lookupUserByContact(phone?: string, email?: string) {
  const or: Record<string, unknown>[] = [];
  if (phone) or.push({ phone });
  if (email) or.push({ email });
  if (or.length === 0) return null;
  return User.findOne({ $or: or });
}

export async function getFamily(userId: string) {
  const oid = new Types.ObjectId(userId);
  const [members, outgoing, incoming] = await Promise.all([
    FamilyMember.find({ ownerId: oid }).sort({ createdAt: 1 }),
    Invitation.find({ senderId: oid, status: 'pending' }).sort({ createdAt: -1 }),
    Invitation.find({ receiverUserId: oid, status: 'pending' }).sort({ createdAt: -1 }),
  ]);

  // Enrich incoming invitations with sender info for the detail card.
  const senderIds = Array.from(new Set(incoming.map((i) => i.senderId.toString())));
  const senders = await User.find({ _id: { $in: senderIds } });
  const senderMap = new Map(senders.map((u) => [u.id as string, u]));

  return {
    members: members.map((m) => m.toJSON()),
    pendingOutgoing: outgoing.map((i) => i.toJSON()),
    pendingIncoming: incoming.map((i) => {
      const s = senderMap.get(i.senderId.toString());
      return {
        ...i.toJSON(),
        sender: s
          ? { id: s.id, name: s.name, avatarUrl: s.avatarUrl, city: s.city }
          : null,
      };
    }),
  };
}

type InviteInput = { name: string; relation: Relation; phone?: string; email?: string };

export async function createInvitation(userId: string, input: InviteInput) {
  const senderId = new Types.ObjectId(userId);
  const phone = normalizePhone(input.phone);
  const email = normalizeEmail(input.email);

  const receiver = await lookupUserByContact(phone, email);

  if (receiver) {
    if (receiver.id === userId) {
      throw new HttpError(400, 'You cannot add yourself');
    }

    const existing = await FamilyMember.findOne({
      ownerId: senderId,
      relativeUserId: receiver._id,
    });
    if (existing) {
      throw new HttpError(409, 'Already connected');
    }

    const duplicate = await Invitation.findOne({
      senderId,
      receiverUserId: receiver._id,
      status: 'pending',
    });
    if (duplicate) {
      return { status: 'sent' as const, invitation: duplicate.toJSON() };
    }

    const invitation = await Invitation.create({
      senderId,
      receiverUserId: receiver._id,
      relation: input.relation,
      proposedName: input.name,
      phone,
      email,
      channel: 'in_app',
    });
    return { status: 'sent' as const, invitation: invitation.toJSON() };
  }

  // User not found — return flag to client; no invitation row created yet.
  return {
    status: 'user_not_registered' as const,
    proposed: { name: input.name, relation: input.relation, phone, email },
  };
}

export async function sendExternalInvite(
  userId: string,
  input: InviteInput & { phone?: string; email?: string }
) {
  const senderId = new Types.ObjectId(userId);
  const phone = normalizePhone(input.phone);
  const email = normalizeEmail(input.email);
  if (!phone && !email) throw new HttpError(400, 'Provide phone or email');

  // If a user exists with these now, convert to in-app invite instead.
  const receiver = await lookupUserByContact(phone, email);
  if (receiver) {
    return createInvitation(userId, {
      name: input.name,
      relation: input.relation,
      phone,
      email,
    });
  }

  const existing = await Invitation.findOne({
    senderId,
    phone: phone ?? null,
    email: email ?? null,
    status: 'pending',
  });
  if (existing) {
    return { status: 'sent' as const, invitation: existing.toJSON() };
  }

  const invitation = await Invitation.create({
    senderId,
    relation: input.relation,
    proposedName: input.name,
    phone,
    email,
    channel: 'external',
  });

  // In production: dispatch SMS/email here. For MVP, nothing else.
  return { status: 'sent' as const, invitation: invitation.toJSON() };
}

export async function acceptInvitation(userId: string, invitationId: string) {
  const inv = await Invitation.findById(invitationId);
  if (!inv) throw new HttpError(404, 'Invitation not found');
  if (inv.status !== 'pending') throw new HttpError(400, 'Invitation already handled');
  if (!inv.receiverUserId || inv.receiverUserId.toString() !== userId) {
    throw new HttpError(403, 'Not your invitation');
  }

  const sender = await User.findById(inv.senderId);
  const receiver = await User.findById(inv.receiverUserId);
  if (!sender || !receiver) throw new HttpError(404, 'User not found');

  const inverse = INVERSE_RELATION[inv.relation];

  // Add two FamilyMember rows (one for each side).
  await FamilyMember.updateOne(
    { ownerId: sender._id, relativeUserId: receiver._id },
    {
      $setOnInsert: {
        ownerId: sender._id,
        relativeUserId: receiver._id,
        relation: inv.relation,
        displayName: receiver.name,
        displayAvatar: receiver.avatarUrl,
        phone: receiver.phone,
        email: receiver.email,
      },
    },
    { upsert: true }
  );
  await FamilyMember.updateOne(
    { ownerId: receiver._id, relativeUserId: sender._id },
    {
      $setOnInsert: {
        ownerId: receiver._id,
        relativeUserId: sender._id,
        relation: inverse,
        displayName: sender.name,
        displayAvatar: sender.avatarUrl,
        phone: sender.phone,
        email: sender.email,
      },
    },
    { upsert: true }
  );

  inv.status = 'accepted';
  await inv.save();

  await Promise.all([
    recomputeCompletion(sender.id as string),
    recomputeCompletion(receiver.id as string),
  ]);

  return inv.toJSON();
}

export async function rejectInvitation(userId: string, invitationId: string) {
  const inv = await Invitation.findById(invitationId);
  if (!inv) throw new HttpError(404, 'Invitation not found');
  if (inv.status !== 'pending') throw new HttpError(400, 'Invitation already handled');
  if (!inv.receiverUserId || inv.receiverUserId.toString() !== userId) {
    throw new HttpError(403, 'Not your invitation');
  }
  inv.status = 'rejected';
  await inv.save();
  return inv.toJSON();
}

export async function cancelInvitation(userId: string, invitationId: string) {
  const inv = await Invitation.findById(invitationId);
  if (!inv) throw new HttpError(404, 'Invitation not found');
  if (inv.senderId.toString() !== userId) throw new HttpError(403, 'Not your invitation');
  if (inv.status !== 'pending') throw new HttpError(400, 'Invitation already handled');
  inv.status = 'cancelled';
  await inv.save();
  return inv.toJSON();
}

export async function removeMember(userId: string, memberId: string) {
  const entry = await FamilyMember.findOne({
    _id: new Types.ObjectId(memberId),
    ownerId: new Types.ObjectId(userId),
  });
  if (!entry) throw new HttpError(404, 'Member not found');
  // Remove both sides.
  const otherOwnerId = entry.relativeUserId?.toString();
  if (entry.relativeUserId) {
    await FamilyMember.deleteOne({
      ownerId: entry.relativeUserId,
      relativeUserId: entry.ownerId,
    });
  }
  await entry.deleteOne();
  await recomputeCompletion(userId);
  if (otherOwnerId) await recomputeCompletion(otherOwnerId);
}

/**
 * On signup (or login), surface any external invitations previously sent by phone/email
 * by linking them to this user's account.
 */
export async function linkExternalInvitations(user: {
  id: string;
  phone?: string;
  email?: string;
}) {
  const or: Record<string, unknown>[] = [];
  if (user.phone) or.push({ phone: user.phone });
  if (user.email) or.push({ email: user.email });
  if (or.length === 0) return 0;
  const result = await Invitation.updateMany(
    { $or: or, status: 'pending', receiverUserId: { $exists: false } },
    { $set: { receiverUserId: new Types.ObjectId(user.id), channel: 'in_app' } }
  );
  return result.modifiedCount;
}
