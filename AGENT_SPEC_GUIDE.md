# Indie Vibe HQ Factory — External Agent Spec Guide

> **Purpose:** This document gives an external AI agent everything it needs to produce
> pre-defined, spec'd-out project plans that the Indie Vibe HQ Operator can execute
> without additional clarification.

---

## 1. What Is Indie Vibe HQ Factory?

A **project scaffolding and lifecycle system** that:

1. Spawns fully-configured **Next.js + TypeScript + Tailwind CSS** projects
2. Injects governance docs, testing config, and UI tooling via overlays
3. Runs verification gates (lint → test → build) before considering a project "ready"
4. Operates in **conversational command mode** — the operator receives a command like
   `"Start a project called my-app"` and executes end-to-end with minimal user intervention

The operator AI reads your spec, fills the project's `docs/` files, and begins building.

---

## 2. Tech Stack (Fixed — Do Not Change)

Every spawned project uses this exact stack. Your specs must design within these constraints.

| Layer           | Technology                          | Notes                                    |
|-----------------|-------------------------------------|------------------------------------------|
| Framework       | **Next.js 15** (App Router)         | Server components by default             |
| Language        | **TypeScript** (strict mode)        | No plain JS files                        |
| Styling         | **Tailwind CSS v4**                 | Utility-first; CSS variables enabled     |
| UI Components   | **shadcn/ui** (New York style)      | Copy-paste components, not a dependency  |
| Icons           | **Lucide React**                    | Only icon library available              |
| Testing         | **Vitest** (default) or Jest        | Vitest preferred; Jest available on flag |
| Test Utils      | **@testing-library/react**          | For component testing                    |
| Linting         | **ESLint** (Next.js config)         | Standard Next.js rules                   |
| Class Merging   | **clsx** + **tailwind-merge**       | Via `cn()` helper at `src/lib/utils.ts`  |
| Variants        | **class-variance-authority (cva)**  | For component variant patterns           |

### What Is NOT Included (Must Be Specified If Needed)

- Database / ORM (e.g., Prisma, Drizzle, Supabase)
- Authentication (e.g., NextAuth, Clerk, Supabase Auth)
- State management (e.g., Zustand, Jotai)
- API layer (e.g., tRPC, REST routes)
- Deployment target (e.g., Vercel, Docker)
- Any backend services

If your spec requires these, list them explicitly with justification.

---

## 3. Project Directory Structure

Every spawned project follows this layout. Your specs should reference these paths.

```
<project-name>/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Home page
│   │   ├── globals.css         # Global styles (Tailwind)
│   │   ├── favicon.ico
│   │   └── <route>/            # Additional routes as page.tsx files
│   │       ├── page.tsx
│   │       ├── layout.tsx      # Optional route layout
│   │       ├── loading.tsx     # Optional loading state
│   │       └── error.tsx       # Optional error boundary
│   ├── components/             # React components
│   │   └── ui/                 # shadcn/ui primitives (auto-added)
│   ├── hooks/                  # Custom React hooks
│   ├── lib/                    # Utilities, helpers, constants
│   │   └── utils.ts            # cn() helper (pre-installed)
│   ├── types/                  # Shared TypeScript interfaces/types
│   └── __tests__/              # Test files
│       └── smoke.test.tsx      # Pre-installed smoke test
├── docs/
│   ├── VISION.md               # ← YOU FILL THIS
│   ├── ARCHITECTURE.md         # Pre-filled with stack info
│   ├── DECISIONS.md            # ← YOU ADD INITIAL DECISIONS
│   └── CHANGELOG.md            # Auto-started
├── public/                     # Static assets
├── AI_RULES.md                 # Governance rules (pre-installed)
├── components.json             # shadcn/ui config (pre-installed)
├── package.json                # Dependencies (pre-configured)
├── tsconfig.json               # TypeScript config
├── next.config.ts              # Next.js config
├── vitest.config.ts            # Test config (if Vitest)
├── vitest.setup.ts             # Test setup (if Vitest)
├── .env.local                  # Environment variables (gitignored)
└── .gitignore
```

---

## 4. Documents You Must Produce

Your project plan must output **three documents** that the operator will inject into the project. These are the primary interface between your spec and the operator's execution.

### 4A. `docs/VISION.md` (REQUIRED)

This is the **most critical document**. The operator reads it first and will STOP if it's empty.

```markdown
# Project Vision

## What is this project?
<!-- One clear paragraph. What does it do? What problem does it solve? -->

## Who is it for?
<!-- Target users. Be specific: "indie musicians who want to..." not "users" -->

## Core Features (MVP)
<!-- Numbered list. Each feature must be concrete and testable. -->
<!-- Example:
1. User can sign up with email/password
2. Artist can upload a track (mp3, max 50MB) with title + cover art
3. Listener can browse tracks by genre
-->

## Success Criteria
<!-- How do we know v1 is done? Measurable where possible. -->

## Out of Scope (for now)
<!-- Explicitly list what we're NOT building. Prevents scope creep. -->
```

**Rules for VISION.md:**
- Every feature in "Core Features" must be achievable with the fixed tech stack
- Features must be ordered by implementation priority (build order)
- Each feature should be small enough to implement in 1-3 files
- No feature should require more than 2 new npm dependencies

### 4B. `docs/DECISIONS.md` — Initial Decisions (REQUIRED)

Pre-populate with key architectural decisions the operator should follow.

```markdown
# Decisions Log

## YYYY-MM-DD — Decision Title
**Context:** Why this decision was needed
**Decision:** What was decided
**Rationale:** Why this option was chosen over alternatives
**Status:** Accepted
```

**Decisions you should pre-make:**
- Database choice and why (if any)
- Auth strategy and why (if any)
- State management approach
- API pattern (server actions vs route handlers vs external API)
- Key data models / entities
- Any additional npm dependencies with justification

### 4C. Feature Breakdown (REQUIRED)

A structured implementation plan the operator can follow step-by-step.

```markdown
# Feature Breakdown

## Feature 1: <Name>
**Priority:** P0 (must-have) | P1 (should-have) | P2 (nice-to-have)
**Depends on:** None | Feature X

### Files to Create/Modify
- `src/app/<route>/page.tsx` — Description of what this page does
- `src/components/<name>.tsx` — Description of component
- `src/lib/<name>.ts` — Description of utility/logic

### Data Model (if applicable)
```typescript
interface Example {
  id: string;
  name: string;
  createdAt: Date;
}
```

### Acceptance Criteria
- [ ] User can do X
- [ ] Page renders Y
- [ ] Test covers Z

### New Dependencies (if any)
- `package-name` — reason, license: MIT
```

---

## 5. Naming Conventions

The operator enforces these. Your specs must follow them.

| Thing              | Convention          | Example                        |
|--------------------|---------------------|--------------------------------|
| Project name       | `kebab-case`        | `indie-music-player`           |
| File names         | `kebab-case`        | `track-card.tsx`               |
| Component names    | `PascalCase`        | `TrackCard`                    |
| Hook names         | `camelCase` + `use` | `useTrackPlayer`               |
| Utility functions  | `camelCase`         | `formatDuration`               |
| Type/Interface     | `PascalCase`        | `Track`, `UserProfile`         |
| Route segments     | `kebab-case`        | `/artist-profile/[id]`         |
| CSS classes        | Tailwind utilities  | `className="flex gap-4 p-2"`  |
| Test files         | `*.test.tsx`        | `track-card.test.tsx`          |
| Imports            | `@/` alias          | `import { cn } from "@/lib/utils"` |

---

## 6. Component Patterns

### Server Components (Default)
```tsx
// src/app/tracks/page.tsx — No "use client" directive
export default async function TracksPage() {
  const tracks = await getTracks(); // Server-side data fetching
  return <TrackList tracks={tracks} />;
}
```

### Client Components (Only When Needed)
```tsx
"use client";
// Required for: useState, useEffect, event handlers, browser APIs
import { useState } from "react";

export function PlayButton({ trackId }: { trackId: string }) {
  const [isPlaying, setIsPlaying] = useState(false);
  return <button onClick={() => setIsPlaying(!isPlaying)}>Play</button>;
}
```

### shadcn/ui Components
```tsx
// Available via: npx shadcn@latest add <component>
// Common ones: button, card, input, dialog, dropdown-menu, avatar, badge
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
```

### cn() Usage for Conditional Classes
```tsx
import { cn } from "@/lib/utils";

<div className={cn("base-classes", isActive && "active-classes")} />
```

---

## 7. Routing (Next.js App Router)

Specs should define routes using this pattern:

```
src/app/
├── page.tsx                    # / (home)
├── layout.tsx                  # Root layout (wraps everything)
├── about/
│   └── page.tsx                # /about
├── tracks/
│   ├── page.tsx                # /tracks (list)
│   └── [id]/
│       └── page.tsx            # /tracks/:id (detail)
├── artist/
│   └── [slug]/
│       └── page.tsx            # /artist/:slug
└── api/
    └── tracks/
        └── route.ts            # API: /api/tracks
```

**Route conventions:**
- Dynamic segments: `[id]`, `[slug]`
- Route groups (no URL impact): `(auth)`, `(dashboard)`
- Parallel routes: `@modal`, `@sidebar`
- Loading states: `loading.tsx` per route
- Error boundaries: `error.tsx` per route
- Not found: `not-found.tsx`

---

## 8. Testing Requirements

Every feature must include tests. The operator runs gates after each increment.

### For Vitest (Default)
```tsx
import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { TrackCard } from "@/components/track-card";

describe("TrackCard", () => {
  it("renders track title", () => {
    render(<TrackCard title="Test Song" artist="Test Artist" />);
    expect(screen.getByText("Test Song")).toBeInTheDocument();
  });
});
```

### For Jest (If Selected)
```tsx
// Same but without vitest imports (globals are available)
import { render, screen } from "@testing-library/react";
import { TrackCard } from "@/components/track-card";

describe("TrackCard", () => {
  it("renders track title", () => {
    render(<TrackCard title="Test Song" artist="Test Artist" />);
    expect(screen.getByText("Test Song")).toBeInTheDocument();
  });
});
```

**Testing rules:**
- Every component gets at least one render test
- Every utility function gets at least one unit test
- Tests live in `src/__tests__/` or colocated as `*.test.tsx`
- Gate: `npm test` must pass before moving to next feature

---

## 9. Dependency Policy

The operator follows strict rules about dependencies. Your spec must respect them.

**Pre-installed (always available):**
- `next`, `react`, `react-dom`
- `typescript`, `@types/react`, `@types/node`
- `tailwindcss`, `@tailwindcss/postcss`
- `eslint`, `eslint-config-next`
- `clsx`, `tailwind-merge`, `class-variance-authority`
- `lucide-react`
- Testing: `vitest` or `jest` + `@testing-library/react` + `@testing-library/jest-dom`

**Must be justified in DECISIONS.md if added:**
- Any new runtime dependency
- Any new dev dependency beyond testing

**Requirements for new dependencies:**
- Must be MIT or Apache-2.0 licensed
- Must have >100 weekly npm downloads
- Must have been updated within the last 6 months
- Must be listed with explicit version in your spec

---

## 10. Output Format — Complete Project Plan

Your final output should be a single document (or structured set) containing:

```markdown
# Project Plan: <project-name>

## Metadata
- **Name:** kebab-case-name
- **Testing:** vitest (default) | jest
- **Additional Dependencies:** list with justification
- **Estimated Features:** N features, M components

## VISION.md Content
<full content to inject into docs/VISION.md>

## DECISIONS.md Content
<full content to inject into docs/DECISIONS.md>

## Feature Breakdown
<structured feature-by-feature plan per Section 4C>

## Route Map
<list of all routes/pages>

## Component Inventory
<list of all components to build with props>

## Data Models
<TypeScript interfaces for all entities>
```

---

## 11. Example: Minimal Project Plan

```markdown
# Project Plan: indie-radio

## Metadata
- **Name:** indie-radio
- **Testing:** vitest
- **Additional Dependencies:** none
- **Estimated Features:** 3 features, 5 components

## VISION.md Content

# Project Vision

## What is this project?
A minimalist web radio player for indie music. Users can browse
curated playlists and stream tracks directly in the browser.

## Who is it for?
Indie music fans who want a simple, distraction-free listening experience.

## Core Features (MVP)
1. Home page with featured playlists
2. Playlist detail page with track listing
3. Audio player bar with play/pause, skip, progress, and volume

## Success Criteria
- User can play a track from a playlist and hear audio
- Player persists across page navigation
- All pages render without errors on mobile and desktop

## Out of Scope (for now)
- User accounts / authentication
- Track uploading
- Search functionality
- Social features (likes, comments)

## DECISIONS.md Content

# Decisions Log

## 2026-02-08 — No Backend for MVP
**Context:** Need to decide on data source for tracks
**Decision:** Use static JSON data files in /src/lib/data/
**Rationale:** Keeps MVP simple; no database needed. Can migrate to API later.
**Status:** Accepted

## 2026-02-08 — Client-Side Audio via HTML5 Audio
**Context:** Need audio playback capability
**Decision:** Use native HTML5 Audio API wrapped in a React context
**Rationale:** No additional dependencies needed. Sufficient for MVP streaming.
**Status:** Accepted

## Feature Breakdown

### Feature 1: Home Page with Featured Playlists
**Priority:** P0
**Depends on:** None

**Files:**
- `src/app/page.tsx` — Home page showing playlist grid
- `src/components/playlist-card.tsx` — Card component for each playlist
- `src/lib/data/playlists.ts` — Static playlist data
- `src/types/playlist.ts` — Playlist type definition

**Acceptance Criteria:**
- [ ] Home page renders grid of playlist cards
- [ ] Each card shows playlist name, cover image, track count
- [ ] Clicking a card navigates to /playlist/[id]
- [ ] Test: PlaylistCard renders with correct data

### Feature 2: Playlist Detail Page
**Priority:** P0
**Depends on:** Feature 1

**Files:**
- `src/app/playlist/[id]/page.tsx` — Playlist detail page
- `src/components/track-row.tsx` — Row component for each track
- `src/lib/data/tracks.ts` — Static track data
- `src/types/track.ts` — Track type definition

**Acceptance Criteria:**
- [ ] Page shows playlist header with name and description
- [ ] Track list renders all tracks with title, artist, duration
- [ ] Clicking a track starts playback
- [ ] Test: TrackRow renders with correct data

### Feature 3: Audio Player Bar
**Priority:** P0
**Depends on:** Feature 2

**Files:**
- `src/components/player-bar.tsx` — Persistent bottom player
- `src/hooks/use-audio-player.ts` — Audio playback hook
- `src/app/layout.tsx` — Modified to include player bar
- `src/components/player-controls.tsx` — Play/pause, skip buttons
- `src/components/progress-bar.tsx` — Seek bar

**Acceptance Criteria:**
- [ ] Player bar appears at bottom when a track is playing
- [ ] Play/pause toggles audio playback
- [ ] Progress bar shows current position and allows seeking
- [ ] Player persists across page navigation via layout
- [ ] Test: PlayerBar renders in playing/paused states
```

---

## 12. Anti-Patterns to Avoid

Your spec should NOT:

- ❌ Assume any backend/database unless explicitly specifying one
- ❌ Reference packages not in the pre-installed list without justification
- ❌ Use `pages/` router (we use App Router only)
- ❌ Specify CSS Modules or styled-components (Tailwind only)
- ❌ Include vague features ("nice UI", "good UX") — be concrete
- ❌ Skip the Out of Scope section
- ❌ Propose more than 10 MVP features (keep it focused)
- ❌ Use global state libraries without justification (React context is usually enough)
- ❌ Reference `jest` globals in Vitest specs (must import from `vitest`)

---

## 13. How the Operator Executes Your Plan

When a user says `"Start a project called <name>"`, the operator:

1. Runs `./iv start <name> --testing=vitest`
2. Reads `docs/VISION.md` — **if empty, the Intake Protocol triggers**
3. If you've provided VISION.md content, the operator injects it
4. Reads `docs/DECISIONS.md` — injects your pre-made decisions
5. Produces a **Requirements Confirmation** summary for the user
6. Gets explicit user confirmation
7. Records confirmation in `docs/DECISIONS.md`
8. Begins implementation following your Feature Breakdown in order
9. After each feature: runs lint → test → build gates
10. Commits with meaningful message
11. Moves to next feature

**Your job is to make steps 2–8 as frictionless as possible.**

---

*This document version: v1.0 — 2026-02-08*
*Factory version: Indie Vibe HQ Factory v9.1*
