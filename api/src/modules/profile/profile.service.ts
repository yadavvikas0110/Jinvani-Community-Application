import { Types } from 'mongoose';
import { HttpError } from '../../middleware/error';
import { FamilyMember } from '../family/family.model';
import { Profile, ProfileDoc } from './profile.model';

const WEIGHTS = {
  personal: 20,
  education: 15,
  work: 15,
  economic: 15,
  bio: 20,
  goals: 10,
  family: 5,
} as const;

function hasAny(obj: Record<string, unknown> | undefined | null) {
  if (!obj) return false;
  return Object.values(obj).some(
    (v) => v !== undefined && v !== null && v !== '' && !(Array.isArray(v) && v.length === 0)
  );
}

function computeCompletion(p: ProfileDoc, familyCount: number): number {
  let pct = 0;
  if (hasAny(p.personalDetails as Record<string, unknown>)) pct += WEIGHTS.personal;
  if (p.education && p.education.length > 0) pct += WEIGHTS.education;
  if (hasAny(p.workDetails as Record<string, unknown>)) pct += WEIGHTS.work;
  const econ = p.economicData;
  if (
    hasAny(econ?.financialInfo as Record<string, unknown>) ||
    hasAny(econ?.futureGoals as Record<string, unknown>) ||
    hasAny(econ?.investmentPortfolio as Record<string, unknown>)
  ) {
    pct += WEIGHTS.economic;
  }
  if (p.bio && (p.bio.avatarUrl || p.bio.briefIntroduction)) pct += WEIGHTS.bio;
  if (p.goals && p.goals.length > 0) pct += WEIGHTS.goals;
  if (familyCount > 0) pct += WEIGHTS.family;
  return Math.min(100, pct);
}

async function loadOrCreate(userId: string): Promise<ProfileDoc> {
  const id = new Types.ObjectId(userId);
  let doc = await Profile.findOne({ userId: id });
  if (!doc) doc = await Profile.create({ userId: id });
  return doc;
}

async function saveWithCompletion(doc: ProfileDoc) {
  const familyCount = await FamilyMember.countDocuments({ ownerId: doc.userId });
  doc.completion = computeCompletion(doc, familyCount);
  await doc.save();
  return doc;
}

export async function recomputeCompletion(userId: string) {
  const doc = await loadOrCreate(userId);
  await saveWithCompletion(doc);
}

export async function getProfile(userId: string) {
  return loadOrCreate(userId);
}

export async function updatePersonal(userId: string, data: Record<string, unknown>) {
  const doc = await loadOrCreate(userId);
  doc.personalDetails = { ...doc.personalDetails, ...data };
  return saveWithCompletion(doc);
}

export async function addEducation(userId: string, data: Record<string, unknown>) {
  const doc = await loadOrCreate(userId);
  doc.education.push(data as never);
  return saveWithCompletion(doc);
}

export async function updateEducation(
  userId: string,
  entryId: string,
  data: Record<string, unknown>
) {
  const doc = await loadOrCreate(userId);
  const entry = doc.education.id(entryId);
  if (!entry) throw new HttpError(404, 'Education entry not found');
  Object.assign(entry, data);
  return saveWithCompletion(doc);
}

export async function removeEducation(userId: string, entryId: string) {
  const doc = await loadOrCreate(userId);
  const entry = doc.education.id(entryId);
  if (!entry) throw new HttpError(404, 'Education entry not found');
  entry.deleteOne();
  return saveWithCompletion(doc);
}

export async function updateWork(userId: string, data: Record<string, unknown>) {
  const doc = await loadOrCreate(userId);
  doc.workDetails = { ...doc.workDetails, ...data };
  return saveWithCompletion(doc);
}

export async function updateEconomic(userId: string, data: Record<string, unknown>) {
  const doc = await loadOrCreate(userId);
  doc.economicData = {
    ...doc.economicData,
    ...(data as Record<string, unknown>),
  } as never;
  return saveWithCompletion(doc);
}

export async function updateBio(userId: string, data: Record<string, unknown>) {
  const doc = await loadOrCreate(userId);
  doc.bio = { ...doc.bio, ...data };
  return saveWithCompletion(doc);
}

export async function updateGoals(userId: string, goals: string[]) {
  const doc = await loadOrCreate(userId);
  doc.goals = goals as never;
  return saveWithCompletion(doc);
}
