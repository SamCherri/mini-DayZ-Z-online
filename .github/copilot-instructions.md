# Repository instructions

This repository is a Godot/GDScript survival RP multiplayer project for Android.

Before editing code, read:

- `README.md`
- `ATTRIBUTION.md`
- `docs/ROADMAP.md`
- `docs/ARCHITECTURE.md`
- `docs/CODEX_TASKS.md`

## Technical direction

- Use Godot/GDScript.
- Keep code modular.
- Prefer a server-authoritative multiplayer architecture.
- Do not treat the client as trusted for critical actions.
- Keep Android controls and mobile performance in mind.
- Preserve attribution and license notices.
- Keep the project clearly marked as a fan/learning project.

## Implementation priorities

1. Import and validate the Godot base.
2. Run offline first.
3. Add basic multiplayer connection.
4. Sync two players.
5. Add RP chat.
6. Add persistence.
7. Test Android export.

## Code style

- Use descriptive file names.
- Keep systems separated by folders.
- Write small commits.
- Prefer readable GDScript over clever abstractions.
- Document assumptions in comments when behavior is not obvious.
