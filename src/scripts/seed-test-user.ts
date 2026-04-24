import 'dotenv/config';
import mongoose from 'mongoose';
import { env } from '../config/env';
import { User } from '../modules/auth/user.model';
import { Profile } from '../modules/profile/profile.model';

const TEST_USERS = [
  {
    name: 'Test User',
    phone: '+919999999999',
    email: 'test@jinvani.dev',
    password: 'Test@1234',
    role: 'member' as const,
    city: 'Mumbai',
  },
  {
    name: 'Priya Shah',
    phone: '+919999988888',
    email: 'priya@jinvani.dev',
    password: 'Test@1234',
    role: 'member' as const,
    city: 'Ahmedabad',
  },
];

async function main() {
  await mongoose.connect(env.MONGODB_URI);
  console.log('Connected:', env.MONGODB_URI);

  for (const t of TEST_USERS) {
    let user = await User.findOne({ phone: t.phone });
    if (user) {
      await user.setPassword(t.password);
      user.isPhoneVerified = true;
      user.name = t.name;
      user.email = t.email;
      user.city = t.city;
      await user.save();
      console.log(`Reset  ${t.phone}  →  ${t.password}`);
    } else {
      user = new User({
        name: t.name,
        phone: t.phone,
        email: t.email,
        role: t.role,
        isPhoneVerified: true,
        city: t.city,
        roles: [],
      });
      await user.setPassword(t.password);
      await user.save();
      console.log(`Create ${t.phone}  →  ${t.password}`);
    }

    const existingProfile = await Profile.findOne({ userId: user._id });
    if (!existingProfile) {
      await Profile.create({
        userId: user._id,
        personalDetails: { fullName: t.name, currentLocation: t.city },
        education: [],
        workDetails: {},
        economicData: {},
        bio: {},
        goals: [],
      });
    }
  }

  console.log('\nLogin from the app with either phone + password above.');
  await mongoose.disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
