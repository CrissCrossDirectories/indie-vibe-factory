# AI Rules — Indie Vibe HQ

## Intake Protocol

Before starting any work on a project:

1. **Read all docs/** files — VISION.md, ARCHITECTURE.md, DECISIONS.md, CHANGELOG.md
2. **Stop immediately** if any required doc is missing or empty
3. Ask the user the minimum questions needed to fill gaps
4. Produce a **Requirements Confirmation** summary
5. Get **explicit user confirmation** before proceeding
6. Record the confirmation in `docs/DECISIONS.md`

## Builder / Auditor Roles

- **Builder**: Implements features in small, testable increments. Each increment must pass lint + test + build before moving on.
- **Auditor**: Reviews code for correctness, security, accessibility, and adherence to ARCHITECTURE.md. Runs after every Builder increment.

## Critique Mode

When asked to review or critique:

1. Start with what's working well (max 2 sentences)
2. List concrete issues with file paths and line numbers
3. Propose specific fixes — no vague suggestions
4. Rate severity: 🔴 blocker, 🟡 warning, 🟢 nit

## Context Rules

- **Stop on missing/empty**: If a referenced file, env var, or config is missing or empty, STOP and report rather than guessing.
- **No hallucinated imports**: Only import packages listed in package.json.
- **No placeholder code**: Every function must have a real implementation or an explicit `// TODO: <reason>` with a tracking issue.

## OSS Preference Rule

- Prefer open-source, MIT/Apache-2.0 licensed packages.
- Before adding any dependency, verify it exists on npm and check its license.
- Avoid packages with fewer than 100 weekly downloads unless justified in DECISIONS.md.
- Prefer well-maintained packages (updated within last 6 months).
