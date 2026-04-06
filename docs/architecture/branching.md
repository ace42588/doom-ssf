# Branching Strategy

## Goals

- Optimize for rapid iteration, not upstream compatibility
- Keep history understandable
- Isolate major refactors and feature work

---

## Branches

### `main`
- Primary integration branch
- Always buildable
- Represents current engine platform

---

## Feature Branches

Naming:

- `feat/<name>` — new capabilities
- `refactor/<name>` — structural changes
- `fix/<name>` — bug fixes
- `chore/<name>` — tooling/docs/build

Examples:

- `feat/library-api`
- `feat/engine-hooks`
- `feat/snapshot-api`
- `refactor/remove-platform-assumptions`

---

## Workflow

1. Branch from `main`
2. Implement a single concern
3. Open PR → `main`
4. Merge via squash or rebase

---

## Rules

- Keep PRs small and focused
- Do not mix unrelated changes
- Prefer deleting branches after merge

---

## Upstream

This repository does NOT track upstream (`ozkl/doomgeneric`) in an ongoing way.

- Upstream is treated as a **bootstrap source**
- Divergence is expected and intentional