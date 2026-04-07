# External Contracts

## Source of Truth

The authoritative cross-boundary contracts for this repository live in the
`doom-contracts` repository.

This repository does not own those contracts. It consumes a pinned version of
them.

The pinned dependency is defined in:

- `contract.lock`

Generated or copied local artifacts, if present, are derived from that source
and must not be edited by hand.

---

## What belongs in `doom-contracts`

Artifacts that cross repository or runtime boundaries belong in `doom-contracts`,
including items such as:

- event schemas
- policy request/response models
- stable snapshot schemas
- shared JSON Schema or OpenAPI definitions
- canonical examples used across multiple repos

---

## What does NOT belong in `doom-contracts`

This repository still owns its local engine implementation details, including:

- internal engine data structures
- engine-only helper types
- private runtime translation logic
- local embedding APIs that are not intended to be shared externally

If a model is only used internally inside this repository and is not part of a
cross-boundary interface, it should remain here.

---

## Current Pinned Version

The current pinned version is defined in `contract.lock`.

Example fields:

- `repository` — location of the source repo
- `ref` — tag or branch intended for resolution
- `commit` — resolved commit SHA actually consumed by this repo

The `commit` is the effective source of truth for reproducibility.

---

## Local Artifact Layout

Derived artifacts are written to:

- `external/generated-contracts/`

That directory is treated as generated content. Files there must not be edited
manually unless there is an explicit temporary exception documented in a PR.

---

## Update Procedure

To update the contracts dependency:

1. Choose the new `doom-contracts` tag or commit.
2. Update `contract.lock`.
3. Run:

   ```bash
   ./tooling/sync-contracts.sh
   ```
4. Review the generated diff carefully.
5. Commit both:
  - the updated contract.lock
  - the regenerated artifacts

---

## Rules

- Do not create duplicate hand-maintained contract definitions in this repo.
- Do not modify generated artifacts manually.
- Any cross-boundary contract change should originate in doom-contracts.
- If this repo needs a new shared contract, add it in doom-contracts first,
then sync it here.

---

## Failure Mode to Avoid

The main risk is silent contract drift, where this repo and `doom-contracts` both define similar but different versions of the same interface.

This repository avoids that by treating `doom-contracts` as authoritative and by pinning a specific dependency version in `contract.lock`.