# Jinvani Community

Monorepo for the Jinvani Community app.

## Structure

- `app/` — Flutter mobile app (Riverpod, go_router, Dio, Hive)
- `api/` — Node.js + Express + TypeScript API (MongoDB/Mongoose, JWT, Zod)
- `design-refs/` — Figma extractions (screenshots + reference code per flow)

## Flows

1. Splash
2. Sign Up
3. Login
4. Forgot Password
5. Community Feed, Posts, Blogs
6. Job Seeker
7. Property Booking
8. Profile
9. Family Tree (4 sub-flows)
10. Jain Calendar
11. Comprehensive Directory
12. Jain Location
13. Jain Community Services
14. Notifications
15. Feedback
16. Customer Support

## Dev

```bash
# API
cd api && npm run dev

# App
cd app && flutter run
```
