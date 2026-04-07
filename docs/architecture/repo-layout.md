# Repository Layout

## Goals

- Separate engine core from integration logic
- Make embedding API explicit and stable
- Avoid leaking internal Doom structures across boundaries
- Enable multiple host environments (Python, WASM, etc.)

---

## Top-Level Structure

```
doom-ssf/
├── engine/ # core engine (derived from upstream, progressively refactored)
├── api/ # public headers (embedding interface)
├── runtime/ # engine-side extensions (hooks, snapshots, dispatch)
├── platforms/ # platform adapters (SDL, headless, wasm)
├── hosts/ # host implementations (python, test harnesses)
├── external/ # external dependencies (contracts)
├── docs/
├── tests/
├── tooling/
```

---

## Directory Responsibilities

### `engine/`

- Contains Doom engine code
- Initially copied from upstream
- Gradually refactored for:
  - library usage
  - hook insertion
  - state inspection

Constraints:

- No host logic
- No external protocol awareness

---

### `api/`

Defines the **only supported interface** for embedding.

Examples:

```
api/dg_engine.h
api/dg_hooks.h
api/dg_snapshot.h
```

Rules:

- Stable, versioned
- No direct exposure of internal structs (`player_t`, `mobj_t`, etc.)

---

### `runtime/`

Bridges engine internals to public API:

- hook dispatch
- snapshot extraction
- internal → external struct translation

This is where most engine modifications should terminate.

---

### `platforms/`

Implements low-level environment bindings:

- framebuffer output
- input handling
- timing

Examples:
```
platform/sdl/
platform/headless/
platform/wasm/
```

---

### `hosts/`

Implements embedding environments:

- Python server integration
- test harnesses
- future web client integration

Responsibilities:

- call engine API
- register hooks
- handle event flow
- request policy decisions

---

### `external/`

This directory is treated as generated content. Files here must not be edited manually. Contains generated/derived dependencies e.g. interface contracts.

---

## Design Constraints

- Engine must not depend on hosts
- Hosts must not depend on engine internals
- All interaction flows through `api/`

---

## Non-Goals

- Preserve upstream file layout
- Maintain compatibility with upstream ports