import { Schema, model, Document, Types } from 'mongoose';

export type EducationType = 'degree' | 'schooling' | 'certification';
export type ProfileGoal = 'business_support' | 'matchmaking' | 'job_assistance';

export interface PersonalDetails {
  fullName?: string;
  age?: number;
  gender?: 'male' | 'female' | 'other';
  birthLocation?: string;
  currentLocation?: string;
  preference?: string;
}

export interface EducationEntry {
  _id: Types.ObjectId;
  type: EducationType;
  degreeName?: string;
  specialization?: string;
  collegeName?: string;
  percentage?: string;
  schoolName?: string;
  stream?: string;
  boardName?: string;
  location?: string;
  achievements?: string;
  certificateUrl?: string;
  certificateName?: string;
  certificateDescription?: string;
}

export interface WorkDetails {
  jobType?: string;
  companyName?: string;
  companyType?: string;
  jobRole?: string;
  yearsOfExperience?: number;
  jobLocation?: string;
  roleDescription?: string;
}

export interface EconomicData {
  financialInfo?: {
    sourceOfIncome?: string;
    jobStatus?: string;
    currentSavings?: number;
  };
  futureGoals?: { goal?: string; description?: string };
  investmentPortfolio?: {
    type?: string;
    currentValue?: number;
    notes?: string;
  };
}

export interface Bio {
  avatarUrl?: string;
  briefIntroduction?: string;
}

export interface ProfileDoc extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  personalDetails: PersonalDetails;
  education: Types.DocumentArray<EducationEntry & Document>;
  workDetails: WorkDetails;
  economicData: EconomicData;
  bio: Bio;
  goals: ProfileGoal[];
  completion: number;
  createdAt: Date;
  updatedAt: Date;
}

const EducationSchema = new Schema<EducationEntry>(
  {
    type: { type: String, enum: ['degree', 'schooling', 'certification'], required: true },
    degreeName: String,
    specialization: String,
    collegeName: String,
    percentage: String,
    schoolName: String,
    stream: String,
    boardName: String,
    location: String,
    achievements: String,
    certificateUrl: String,
    certificateName: String,
    certificateDescription: String,
  },
  { _id: true, timestamps: false }
);

const ProfileSchema = new Schema<ProfileDoc>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true, index: true },
    personalDetails: {
      fullName: String,
      age: Number,
      gender: { type: String, enum: ['male', 'female', 'other'] },
      birthLocation: String,
      currentLocation: String,
      preference: String,
    },
    education: { type: [EducationSchema], default: [] },
    workDetails: {
      jobType: String,
      companyName: String,
      companyType: String,
      jobRole: String,
      yearsOfExperience: Number,
      jobLocation: String,
      roleDescription: String,
    },
    economicData: {
      financialInfo: {
        sourceOfIncome: String,
        jobStatus: String,
        currentSavings: Number,
      },
      futureGoals: { goal: String, description: String },
      investmentPortfolio: {
        type: { type: String },
        currentValue: Number,
        notes: String,
      },
    },
    bio: {
      avatarUrl: String,
      briefIntroduction: String,
    },
    goals: { type: [String], default: [] },
    completion: { type: Number, default: 0 },
  },
  { timestamps: true }
);

ProfileSchema.set('toJSON', {
  transform: (_doc, ret) => {
    const r = ret as unknown as Record<string, unknown>;
    r.id = r._id;
    delete r._id;
    delete r.__v;
    return r;
  },
});

export const Profile = model<ProfileDoc>('Profile', ProfileSchema);
