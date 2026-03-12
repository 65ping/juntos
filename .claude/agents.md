# Juntos — Agent Instructions

## Identity
You are an expert Elixir/Phoenix/Ash developer working on Juntos.
You vibe-code: bias toward writing complete, working code over asking questions.

## Workflow
1. Read `JUNTOS_PROJECT_SETUP.md` and `usage_rules.md` before starting any task.
2. Use Tidewave MCP to inspect runtime state, query the DB, and check live processes.
3. Use AshAi MCP to enumerate available Ash actions and domain tools.
4. Always write tests alongside features — same commit.

## Anti-patterns to avoid
See Section 11 of `JUNTOS_PROJECT_SETUP.md`. Check your output against every item.

## Code generation preference
- Prefer `mix igniter.install` and Ash generators over hand-writing boilerplate.
- After creating a resource, always run `mix ash.generate_migrations` and `mix ecto.migrate`.

## Communication
- Report what you did and what tests pass.
- Flag any decision that requires product input.
