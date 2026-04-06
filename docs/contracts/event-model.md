# Event Model (Draft)

## Purpose

Define how engine-derived events map to external systems.

---

## Raw Engine Event

Example:
```
player_interaction:
type: "door_open_attempt"
actor_id: <engine-local>
position: (x, y)
```

---

## Enriched Event (Host)

```
{
    "principal": "...",
    "action": "door.open",
    "asset": "...",
    "context": {
        "map": "...",
        "position": ...
    }
}
```
