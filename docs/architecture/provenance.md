# Provenance

## Origin

This project is derived from:

https://github.com/ozkl/doomgeneric

---

## Intentional Divergence

This fork:

- converts the engine into a reusable library
- introduces explicit host/engine contracts
- adds hooks, snapshots, and policy integration points
- removes assumptions about platform ownership

It is NOT intended to remain API- or structure-compatible with upstream.

---

## Baseline Reference

The initial upstream state is preserved via:

- Git history (fork point)
- Optional tag:

```bash
git tag upstream-baseline
```

---

## When to Revisit Upstream

Only consider pulling from upstream if:
- a critical bug exists in unchanged engine code
- a change is isolated and easy to port

Otherwise:
- treat upstream as read-only reference material

---

## Philosophy

- Upstream = historical implementation
- This repo = evolving platform

Do not constrain design decisions to preserve upstream compatibility.

---
