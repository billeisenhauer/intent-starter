# Applications

This folder contains **implementations** of the system identity defined in `truth/`.

All applications here are replaceable.
They express truth — they do not define it.

## Relationship to Truth

- `truth/` defines what the system IS
- `apps/` contains how the system is currently BUILT

If an app can be regenerated without changing system identity,
it belongs here.

## Structure

Each subfolder is a separate implementation:

```
apps/
├── rails-web/
│   ├── pace-mapping.yml  # Maps paths to abstract pace layers
│   ├── app/
│   ├── config/
│   └── ...
├── rails-worker/         # Background job processor (optional)
└── admin-ui/             # Internal tooling (optional)
```

## Pace Mapping

Each app must include a `pace-mapping.yml` that maps its file paths
to the abstract pace layers defined in `truth/pace/layers.yml`.

This allows:
- Truth to remain framework-agnostic
- Each app to declare its own structure
- Consistent enforcement across implementations

All implementations must pass `truth:verify`.
