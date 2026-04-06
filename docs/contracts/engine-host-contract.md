# Engine ↔ Host Contract

## Purpose

Define a stable interface between:

- engine (C)
- host environments (Python, JS, etc.)

---

## Principles

1. Engine exposes facts, not meaning
2. Host assigns identity and context
3. Interface must remain small and stable
4. No transport or protocol logic in engine

---

## Responsibilities

### Engine

- Advance simulation (`tick`)
- Maintain world state
- Trigger hooks for significant events
- Provide snapshots of internal state
- Render framebuffer

---

### Host

- Provide platform bindings (input, timing, display)
- Enrich events with identity/session
- Perform policy decisions
- Emit external events (CAEP, RISC, etc.)
- Persist or forward state

---

## Lifecycle API

```c
dg_engine_t* dg_engine_create(const dg_config_t*);
void dg_engine_tick(dg_engine_t*);
void dg_engine_destroy(dg_engine_t*);
```

---

## Callback Registration

```c
void dg_register_hooks(dg_engine_t* engine, const dg_hooks_t* hooks);
```

Example hook categories:
- player_spawn
- player_death
- level_start
- level_end
- interaction (door, switch, pickup)

---

## Snapshot API (Draft)

```c
int dg_snapshot_player(dg_engine_t*, dg_player_snapshot_t*);
int dg_snapshot_world(dg_engine_t*, dg_world_snapshot_t*);
```

Snapshots must:
- be read-only
- avoid exposing raw engine structs directly
- remain stable across versions

---

## Event Flow

```
[Engine Tick]
     ↓
[Hook Triggered]
     ↓
[Host Callback]
     ↓
[Host Enrichment]
     ↓
[Policy Decision (optional)]
     ↓
[External Event / Action]
```

---

## Policy Decision Pattern

1. Engine emits "intent" (e.g., door open attempt)
2. Host decides:
    - allow
    - deny
    - modify
3. Host feeds result back into engine
4. Engine applies result

---

## Anti-Patterns

- Embedding JSON or HTTP logic in engine
- Passing raw internal structs across boundary
- Introducing identity/session concepts in engine

---

## Versioning Strategy

- API versioned independently from engine internals
- Breaking changes require explicit version bump