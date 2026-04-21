# Sign Up Flow

## Screens

| # | Node ID | Purpose |
|---|---------|---------|
| 1 | 592:31064 | Step 1 — Enter Details (Name / Email / Mobile) empty |
| 2 | 592:31156 | Step 1 filled |
| 3 | 592:31248 | Step 2 — Enter OTP (6 boxes) empty |
| 4 | 592:31319 | Step 2 filled |
| 5 | 592:31390 | Step 3 — Create Password (header says "Reset Password") |
| 6 | 592:31473 | Step 3 with password strength + rules (8 chars, number, symbol) |
| 7 | 592:31567 | Choose Roles (multi-select) |
| 8 | 592:31662 | Roles selected state |
| 9 | 592:31758 | Login screen (linked as "Already have an account? Login") |

## API flow

1. **POST /auth/signup/start** `{name, email, phone}` → creates OTP, returns `{expiresInSec}`. No user created yet.
2. **POST /auth/signup/verify-otp** `{phone, code}` → returns short-lived `signupToken` (JWT, 15 min).
3. **POST /auth/signup/complete** `{signupToken, password}` → creates user, returns `{user, accessToken, refreshToken}`.
4. **POST /users/me/roles** `{roles: []}` (authenticated) → updates role tags.

## Design tokens

- **Header gradient**: `linear-gradient(133.97deg, #0E2468 0%, #4D2063 98%)`
- **Primary button gradient**: `#193361 → #5970AF (47%) → #985AC0` horizontal
- **Accent link**: `#9439D5`
- **Text primary**: `#121A2C`
- **Text secondary**: `#737B8C`
- **Text tertiary / placeholder**: `#9EA1A8`
- **Border**: `#AAB2BC`
- **Radius**: 12px
- **Input height**: 48px
- **Font**: Inter (Regular, Medium, SemiBold, Bold)

## Roles list

Jain Businessman, Jain Professional, Jain Social Workers, Jain Youth Groups, Jain Women's Organizations, Jain Scholars & Speakers, Jain Philanthropists
