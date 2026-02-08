# Project Name

> Scaffolded by **Indie Vibe HQ Factory v9.1**

## Getting Started

```bash
npm run dev      # Start development server
npm run lint     # Run ESLint
npm test         # Run tests
npm run build    # Production build
```

## Project Structure

```
src/
├── app/              # Next.js App Router pages & layouts
├── components/       # React components
│   └── ui/           # shadcn/ui components
├── hooks/            # Custom React hooks
├── lib/              # Utility functions & shared logic
│   └── utils.ts      # cn() helper for Tailwind class merging
└── __tests__/        # Test files

docs/
├── ARCHITECTURE.md   # Technical architecture & stack decisions
├── DECISIONS.md      # Decision log (append-only)
├── VISION.md         # Product vision & requirements
└── CHANGELOG.md      # Version history
```

## Stack

- **Framework:** Next.js 15 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS v4
- **UI Components:** shadcn/ui (New York style)
- **Icons:** Lucide React

## AI Rules

See [AI_RULES.md](./AI_RULES.md) for the governance rules that AI assistants must follow when working on this project.

## Docs

All project documentation lives in the `docs/` directory. Read `docs/VISION.md` first, then `docs/ARCHITECTURE.md`.
