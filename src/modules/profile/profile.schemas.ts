import { z } from 'zod';

export const personalDetailsSchema = z.object({
  fullName: z.string().min(2).max(80).optional(),
  age: z.number().int().min(1).max(120).optional(),
  gender: z.enum(['male', 'female', 'other']).optional(),
  birthLocation: z.string().max(120).optional(),
  currentLocation: z.string().max(120).optional(),
  preference: z.string().max(120).optional(),
});

const baseEducation = z.object({
  type: z.enum(['degree', 'schooling', 'certification']),
  degreeName: z.string().max(120).optional(),
  specialization: z.string().max(120).optional(),
  collegeName: z.string().max(120).optional(),
  percentage: z.string().max(20).optional(),
  schoolName: z.string().max(120).optional(),
  stream: z.string().max(60).optional(),
  boardName: z.string().max(60).optional(),
  location: z.string().max(120).optional(),
  achievements: z.string().max(500).optional(),
  certificateUrl: z.string().url().optional(),
  certificateName: z.string().max(120).optional(),
  certificateDescription: z.string().max(500).optional(),
});
export const addEducationSchema = baseEducation;
export const updateEducationSchema = baseEducation.partial();

export const workDetailsSchema = z.object({
  jobType: z.string().max(60).optional(),
  companyName: z.string().max(120).optional(),
  companyType: z.string().max(60).optional(),
  jobRole: z.string().max(120).optional(),
  yearsOfExperience: z.number().int().min(0).max(80).optional(),
  jobLocation: z.string().max(120).optional(),
  roleDescription: z.string().max(500).optional(),
});

export const economicDataSchema = z.object({
  financialInfo: z
    .object({
      sourceOfIncome: z.string().max(60).optional(),
      jobStatus: z.string().max(60).optional(),
      currentSavings: z.number().nonnegative().optional(),
    })
    .optional(),
  futureGoals: z
    .object({
      goal: z.string().max(120).optional(),
      description: z.string().max(500).optional(),
    })
    .optional(),
  investmentPortfolio: z
    .object({
      type: z.string().max(60).optional(),
      currentValue: z.number().nonnegative().optional(),
      notes: z.string().max(500).optional(),
    })
    .optional(),
});

export const bioSchema = z.object({
  avatarUrl: z.string().url().optional(),
  briefIntroduction: z.string().max(500).optional(),
});

export const goalsSchema = z.object({
  goals: z.array(z.enum(['business_support', 'matchmaking', 'job_assistance'])).max(3),
});
