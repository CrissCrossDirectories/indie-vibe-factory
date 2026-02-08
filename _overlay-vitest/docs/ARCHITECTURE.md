# Architecture

## Tech Stack

| Layer         | Technology                        |
|---------------|-----------------------------------|
| Framework     | Next.js 15 (App Router)           |
| Language      | TypeScript (strict mode)          |
| Styling       | Tailwind CSS v4                   |
| UI Components | shadcn/ui (New York style)        |
| Icons         | Lucide React                      |
| Testing       | Vitest (fast lane)                |
| Test Utils    | @testing-library/react            |
| Linting       | ESLint (Next.js config)           |

## Directory Layout

```
src/
├── app/              # Next.js App Router (pages, layouts, route handlers)
├── components/       # Reusable React components
│   └── ui/           # shadcn/ui primitives
├── hooks/            # Custom React hooks
├── lib/              # Shared utilities, helpers, constants
│   └── utils.ts      # cn() — Tailwind class merging
├── types/            # Shared TypeScript types/interfaces
└── __tests__/        # Test files (colocated or centralized)
```

## Conventions

- **File naming:** kebab-case for files, PascalCase for components
- **Imports:** Use `@/` path alias for all `src/` imports
- **Components:** One component per file; export as named export
- **Tests:** Colocate with source or place in `__tests__/`; suffix `.test.tsx`
- **State:** Prefer server components; use `"use client"` only when necessary
- **Error handling:** Use Next.js error boundaries (`error.tsx`) per route segment

## Testing Strategy

- **Unit tests:** Component rendering, utility functions
- **Integration tests:** Page-level rendering with mocked data
- **Gate:** All tests must pass before any commit (`npm test`)
- **Runner:** Vitest with jsdom environment, configured via `vitest.config.ts`
- **Globals:** Disabled — explicit imports from `vitest` required
