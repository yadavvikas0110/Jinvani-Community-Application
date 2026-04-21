# Profile Flow

## Screens

| # | Node ID | Purpose |
|---|---------|---------|
| 1 | 592:29023 | Home Page — profile completion card at top + bottom nav (Home/Feed/Jobs/Booking/Profile) |
| 2 | 592:29283 | **Profile Menu** — hub listing 7 sections (1 Personal [Required], 2 Educational [Opt], 3 Work [Opt], 4 Economic [Opt], 5 Picture & Bio [Required], 6 Goal Selection [Opt], 7 Family Tree [Opt]) |
| 3 | 592:29387 | Personal Details — Full Name / Age / Gender / Birth Location / Current Location / Preference |
| 4 | 592:29497 | Educational Details — **Degree** tab (Degree Name / Specialization / College Name / Percentage-CGPA + Add Degree button) |
| 5 | 592:30149 | Educational Details — Degree Added (list view of saved degrees with edit/delete) |
| 6 | 592:29596 | Educational Details — **Schooling** tab (School / Stream / Board / Location / % / Achievements) |
| 7 | 592:29724 | Educational Details — **Certification** tab (Upload + Name + Description) |
| 8 | 592:29799 | Work Details — Job Type / Company Name / Company Type / Job Role / Years of Experience / Job Location / Role Description |
| 9 | 592:29923 | Economic Data — Financial Info (Source/Status/Savings) + Future Goals (Goal/Description) + Investment Portfolio (Type/Value/Notes) |
| 10 | 592:30093 | Profile Picture & Bio — Upload photo (circular, 400×400px recommended, 5MB max) + Brief Introduction (500 char) |
| 11 | 592:30074 | Goal Selection — Multi-select cards: Business Support / Matchmaking / Job Assistance |

## Layout pattern

- **AppBar**: white background, centered bold "Profile" title, back arrow on left, no gradient.
- **Page bg**: light neutral gray (#F5F5F5).
- **Section title**: bold ~20px + gray subtitle (description of that section).
- **Form card**: white, rounded 12px, padded 16px.
- **Inputs**: label above, 48px input with 12px radius and light gray border.
- **Action bar (sticky bottom)**: gradient "Save & Continue" primary + flat gray "Skip for now" secondary (secondary only on optional sections).
- **Goal Selection**: finishes with "Finish Profile Setup" gradient button, no skip.

## Tabs for Education

Three tabs at top of Educational Details: Degree / Schooling / Certification. Selected tab = white pill with blue text; others = plain text on light gray.

## API sketch

```
GET    /users/me/profile              -> full profile
PUT    /users/me/profile/personal     -> personalDetails
POST   /users/me/profile/education    -> add education (degree|schooling|certification)
PUT    /users/me/profile/education/:id
DELETE /users/me/profile/education/:id
PUT    /users/me/profile/work         -> workDetails
PUT    /users/me/profile/economic     -> economicData
PUT    /users/me/profile/bio          -> avatarUrl + bio
PUT    /users/me/profile/goals        -> goals[]
POST   /users/me/profile/avatar       -> multipart upload, returns url
POST   /users/me/profile/certificate  -> multipart upload, returns url
```

Completion % is derived: personal (20) + edu (15) + work (15) + economic (15) + bio (20) + goals (10) + family (5).
