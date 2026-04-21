# Family Tree Flow

Source: Figma `Family Tree Flow` section (node `614:15170`). 29 Figma frames collapse to **6 logical screens** — the rest are state variants of Home/Profile/Hub under different conditions (existing user / unregistered invitee / pending state / empty state).

## Flow narrative

The flow revolves around **invitations**: the sender enters a family member's name/relation + phone or email. Two branches:

- **If the recipient already has a Jinvani account** → a Family Request is created; recipient gets it on Home and can Accept/Reject. On accept, the edge is added to both trees.
- **If recipient is NOT registered** → an Invite (by phone/email) is stored. When they sign up with that phone/email, the pending invitation surfaces on their Home and they can accept to connect.

## Screens

| # | Node ID refs | Logical screen |
|---|--------------|----------------|
| 1 | 607:12351, 613:13519 | **Family Tree Hub** — dark navy card with circular avatars of existing members around central "You", + "Add Members" CTA, + "Pending Invitations" list beneath |
| 2 | 607:12403 | **Add Family Member** — Name, Relation (dropdown), Mobile and/or Email, plus "Continue" CTA. Info banner: adding both channels improves delivery. |
| 3 | 613:12993 | **User Not Registered dialog** — modal over Add Member form: "<name> is not registered on Jinvani. Send an invite to connect with them." Mobile+Email fields and Send Invite / Cancel buttons |
| 4 | 600:10375 | **Family Requests list** — when receiver taps the Home banner; each card: avatar, name, "Wants to add you as brother", mutual connections count, "View Request" button |
| 5 | 600:10649, 603:11049, 605:11262, 605:11417 | **Family Request detail** — gradient hero with avatar + name, "X wants to add you as Y", Relation chip, security note, sticky Reject (red) + Accept (green) buttons |
| 6 | 599:9422, 599:9682, 599:9951 (Home variants) | **Home banner/tile** — "N Family Requests" callout + "Family" quick-view tile; tapping navigates to screen #4 |

Profile menu entry for Family Tree (item #7) is already wired in the Profile flow (see `design-refs/profile/FLOW.md`). This flow owns the Family Tree hub and downstream screens.

## Layout patterns

- **AppBar**: white, centered "Family Tree" / "Family Requests" / "Add Members" title, back arrow.
- **Family Tree canvas** (hub): dark navy (#12122B-ish) rounded 20px card; avatars are 64px circles with white border; names below in white bold, relation below in small muted white.
- **Add Member info banner**: light purple background, `info` icon, "Adding both mobile and email lets us reach them via **multiple channels** for a higher chance of delivery."
- **Request card** (list): white card, radius 12, left avatar, right "View Request" pill (gradient). Sub-line "Wants to add you as <relation>" in light purple background.
- **Request detail**: gradient header card with large circular avatar and centered name + location; relation chip; green "Accept" and red "Reject" bottom action bar (full-width, 2 columns).
- **Pending Invitation card** (on hub): white card, radius 12, square gradient avatar initials, name + relation, right-side orange "Pending" pill, second row with phone and email.

## API sketch

```
GET    /users/me/family                 → { members: [...], pendingOutgoing: [...], pendingIncoming: [...] }
POST   /users/me/family/invite          → body: { name, relation, phone?, email? }
                                            returns: { status: 'sent' | 'user_not_registered', invitationId?, user? }
POST   /users/me/family/invite/:id/send → send external invite (SMS/email), only for user_not_registered path
POST   /users/me/family/requests/:id/accept
POST   /users/me/family/requests/:id/reject
DELETE /users/me/family/members/:id     → remove a member (both sides)
```

Relations (enum): `father`, `mother`, `brother`, `sister`, `son`, `daughter`, `spouse`, `uncle`, `aunt`, `cousin`, `grandfather`, `grandmother`, `other`.

Each relation has an inverse that the backend computes when accepting, e.g. sender says "add X as brother" → accepted, receiver's tree gets sender as `brother` back.

## Completion weight

Already allocated 5 points in `computeCompletion` under the `family` bucket. Trigger: any accepted family member on the tree.
