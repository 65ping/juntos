# Juntos — Claude Code Usage Rules

## Non-negotiable
- Always use Ash Framework for all data access. Never use raw Ecto queries.
- Every new Ash resource must declare both `sqlite` and `postgres` data layer blocks.
- All business logic lives in Ash actions and changes — not in LiveView callbacks.
- LiveView callbacks only call Ash actions or read from assigns.
- Tests must be written for every feature, targeting ~80% coverage.
- Never commit secrets. Use `System.fetch_env!/1` in prod config.
- Follow all Elixir anti-pattern guidance (see Section 11 of JUNTOS_PROJECT_SETUP.md).

## Naming
- Ash domains: PascalCase module under `Juntos.<Context>`
- LiveView modules: `JuntosWeb.<Context>.<Feature>Live`
- Svelte components: PascalCase, co-located with their LiveView

## Formatting
- Run `mix format` before every commit.
- Elixir line length: 98 chars.

## Testing
- Use `Ash.Test` helpers for resource tests.
- Use `Phoenix.LiveViewTest` for LiveView tests.
- Use `ex_machina` factories for test data.
- Mock external services with `mox` — never hit real APIs in tests.

## Background Jobs
- Use Oban only when a task must be deferred or retried.
- Every Oban worker must have a corresponding unit test.

## Migrations
- Always generate migrations with `mix ash.generate_migrations`.
- Never hand-write Ecto migrations.
