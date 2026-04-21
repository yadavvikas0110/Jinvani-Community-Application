# Community Feed Flow

Source: Figma section "Community Feed, Posts and Blogs Flow" (node `592:30263`). 5 primary frames collapse to **4 logical screens**.

## Flow narrative

Two content types share one feed surface:

- **Posts** — short text updates (optional image). Actions: Like, Comment, Share, Save.
- **Blogs** — longer form, **required** cover image + title + body. Same save/share affordances.

The feed screen has a top tab switcher: **Community Feed** (posts) / **Blogs & Articles**. A sticky blue "Share your thoughts" / "Write a blog…" composer pill sits below the tabs, opens the corresponding bottom-sheet composer. Bottom navigation — Home / Feed / Jobs / Booking / Profile — is global.

## Screens

| # | Node ID | Logical screen |
|---|---------|----------------|
| 1 | 592:30524 | **Community Feed (Posts tab)** — tab header, composer pill, Quick View section header with "Latest" filter pill, list of post cards |
| 2 | 592:30643 | **Blogs & Articles tab** — same chrome, list of blog cards (cover image + title + excerpt + author row) |
| 3 | 592:30906 | **Add Post** — bottom-sheet modal over feed: "Create Post" header, avatar + "Posting Publicly", Title field, "What's on your mind?" body, Add Image button, Post CTA |
| 4 | 592:30722 | **Add Blog** — same pattern as Add Post but with larger body + required cover image |

(The 5th Figma frame `592:30264` "Home Page" is just a context reference — not a new screen.)

## Layout patterns

- **Tabs header** — white background, drop shadow (`0 4 8 rgba(0,0,0,0.1)`); active tab underlined with #3D629A (2px), inactive tabs #6B7280
- **Composer pill** — #446BA5 blue card, 8px radius, avatar + light input pill (placeholder text) + white-20% circular send button
- **Section header row** — "Quick View" (14px bold) + "Latest" sort pill (#FAB110 yellow, 10px text, caret)
- **Post card** — white bg, 12px radius, 1px #E1E3E6 border, 1px gap between header/body block and footer (simulating divider):
  - Header: 40px avatar, name (#121A2C 14px medium), sub (#ABAFB9 10px regular — "{role} {city} {time}"), 3-dot menu
  - Body: 12px regular text (#4C4A53)
  - Footer: Like (filled red when liked) + count, Comment + count, Share + count, right-aligned bookmark
- **Blog card** — white bg, shadow `0 12 16 rgba(16,24,40,0.08)`, 8px cover image on top, 16px semibold title with arrow-up-right chevron, 14px regular excerpt (#667085), 1px gap before author footer row (author avatar, name, time, bookmark)
- **Create modal (bottom sheet)** — rounded-top 12px, header row ("Create Post" + X close), user row (avatar + name + "Posting Publicly"), Title field (48px rounded input), body textarea, Add Image row (white with icon), Post button — disabled grey until content is entered

## API sketch

```
GET    /feed?type=post|blog&cursor=X&limit=20   → { items: [...], nextCursor }
POST   /feed                                    → body: { type, title?, body, imageUrl? }
GET    /feed/:id                                → single post with comments
DELETE /feed/:id                                → own post only
POST   /feed/:id/like                           → toggles
POST   /feed/:id/comment                        → body: { text }
DELETE /feed/:id/comment/:commentId             → own comment only
POST   /feed/:id/save                           → toggles bookmark
GET    /feed/saved                              → current user's saved posts
POST   /feed/upload                             → multipart image upload → returns { url }
```

Post shape returned:
```
{
  id, type: 'post'|'blog', author: { id, name, avatarUrl, role, city },
  title?, body, imageUrl?, createdAt,
  counts: { likes, comments, shares },
  viewer: { liked, saved }
}
```

## Completion weight

Posting does **not** contribute to profile completion. Feed is a community engagement feature, not a profile gate.
