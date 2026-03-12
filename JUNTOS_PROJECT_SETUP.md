# Juntos — Project Setup Guide for Claude Code

> This document is intended to be shared with Claude Code as the canonical reference for bootstrapping and developing the Juntos project. Follow it precisely and reference it throughout development.

---

## 1. Project Identity

| Field | Value |
|---|---|
| **Project name** | Juntos |
| **OTP app name** | `juntos` |
| **Purpose** | TBD (defined separately in product spec) |

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Language | Elixir |
| Web framework | Phoenix (latest stable) |
| UI rendering | Phoenix LiveView + live_svelte |
| Styling | Tailwind CSS |
| Data modelling | Ash Framework |
| Background jobs | Oban (when needed) |
| Dev/Test DB | SQLite via `ecto_sqlite3` |
| Prod DB | PostgreSQL via `ash_postgres` |
| MCP (dev) | Tidewave + AshAi dev MCP |

---

## 3. Bootstrapping the Project

### 3.1 Create the Phoenix App

```bash
mix igniter.new juntos \
  --with phx.new \
  --install ash,ash_sqlite,ash_phoenix \
  --install ash_authentication_phoenix \
  --install live_svelte \
  --no-ecto
```

> Note: We manage the Ecto adapter manually (SQLite in dev/test, Postgres in prod) so skip the default generator's Ecto flags and configure manually.

### 3.2 Dependencies (`mix.exs`)

```elixir
defp deps do
  [
    # Core Phoenix
    {:phoenix, "~> 1.7"},
    {:phoenix_ecto, "~> 4.4"},
    {:phoenix_html, "~> 4.0"},
    {:phoenix_live_reload, "~> 1.2", only: :dev},
    {:phoenix_live_view, "~> 1.0"},
    {:phoenix_live_dashboard, "~> 0.8"},
    {:floki, ">= 0.30.0", only: :test},
    {:swoosh, "~> 1.5"},
    {:finch, "~> 0.13"},
    {:telemetry_metrics, "~> 1.0"},
    {:telemetry_poller, "~> 1.0"},
    {:gettext, "~> 0.20"},
    {:jason, "~> 1.2"},
    {:dns_cluster, "~> 0.1.1"},
    {:bandit, "~> 1.5"},

    # Ash ecosystem
    {:ash, "~> 3.0"},
    {:ash_phoenix, "~> 2.0"},
    {:ash_authentication, "~> 4.0"},
    {:ash_authentication_phoenix, "~> 2.0"},

    # Database — env-split
    {:ash_sqlite, "~> 0.2", only: [:dev, :test]},
    {:ecto_sqlite3, "~> 0.17", only: [:dev, :test]},
    {:ash_postgres, "~> 2.0"},
    {:postgrex, ">= 0.0.0"},

    # UI
    {:live_svelte, "~> 0.14"},

    # Tailwind / esbuild
    {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
    {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},

    # Background jobs
    {:oban, "~> 2.19"},
    {:ash_oban, "~> 0.3"},

    # MCP / AI tooling
    {:tidewave, "~> 0.1", only: :dev},
    {:ash_ai, "~> 0.2"},

    # Igniter (codegen)
    {:igniter, "~> 0.5", only: [:dev, :test]},

    # Test helpers
    {:ex_machina, "~> 2.8", only: :test},
    {:mox, "~> 1.0", only: :test},
    {:bypass, "~> 2.1", only: :test}
  ]
end
```

---

## 4. Environment-Split Database Configuration

### 4.1 `config/config.exs` (shared)

```elixir
config :juntos, Juntos.Repo,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

### 4.2 `config/dev.exs`

```elixir
config :juntos, Juntos.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../juntos_dev.db", Path.dirname(__ENV__.file))

config :juntos, :ash_domains, [Juntos.Accounts, Juntos.Core]
```

### 4.3 `config/test.exs`

```elixir
config :juntos, Juntos.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: Path.expand("../juntos_test.db", Path.dirname(__ENV__.file)),
  pool: Ecto.Adapters.SQL.Sandbox
```

### 4.4 `config/prod.exs`

```elixir
config :juntos, Juntos.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
```

### 4.5 Repo Module

```elixir
defmodule Juntos.Repo do
  use AshPostgres.Repo, otp_app: :juntos
  use AshSqlite.Repo, otp_app: :juntos

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
```

> The Repo module includes both `AshPostgres.Repo` and `AshSqlite.Repo`. Ash resolves the correct adapter at runtime based on the configured adapter.

---

## 5. Ash Domain & Resource Conventions

### 5.1 Domain Structure

```
lib/juntos/
  accounts/
    accounts.ex          # Ash.Domain
    user.ex              # Ash.Resource
    token.ex
  core/
    core.ex              # Ash.Domain (feature-specific)
    <resource>.ex
```

### 5.2 Domain Module Pattern

```elixir
defmodule Juntos.Accounts do
  use Ash.Domain, extensions: [AshAi]

  resources do
    resource Juntos.Accounts.User
    resource Juntos.Accounts.Token
  end

  # Expose actions as MCP tools (for dev AI agent use)
  tools do
    tool :list_users, Juntos.Accounts.User, :read
  end
end
```

### 5.3 Resource Module Pattern

```elixir
defmodule Juntos.Accounts.User do
  use Ash.Resource,
    domain: Juntos.Accounts,
    data_layer: AshSqlite.DataLayer,  # overridden to AshPostgres in prod via config
    extensions: [AshAuthentication]

  sqlite do
    table "users"
    repo Juntos.Repo
  end

  postgres do
    table "users"
    repo Juntos.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  identities do
    identity :unique_email, [:email]
  end

  actions do
    defaults [:read, :destroy]
    # Define create/update explicitly for type safety
  end
end
```

---

## 6. MCP Integration

### 6.1 Tidewave (dev runtime visibility)

In `lib/juntos_web/endpoint.ex`:

```elixir
if code_reloading? do
  socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
  plug Phoenix.LiveReloader
  plug Phoenix.CodeReloader

  # Tidewave MCP
  plug Tidewave
end
```

### 6.2 AshAi Dev MCP

Also inside the `code_reloading?` block:

```elixir
plug AshAi.Mcp.Dev,
  protocol_version_statement: "2024-11-05",
  otp_app: :juntos
```

Default endpoint: `http://localhost:4000/ash_ai/mcp`

### 6.3 Claude Code MCP Configuration (`.claude/mcp.json`)

```json
{
  "mcpServers": {
    "tidewave": {
      "type": "sse",
      "url": "http://localhost:4000/tidewave/mcp"
    },
    "ash_ai": {
      "type": "sse",
      "url": "http://localhost:4000/ash_ai/mcp"
    }
  }
}
```

---

## 7. Usage Rules & Agents Configuration

### 7.1 `.claude/usage_rules.md`

Create this file. It is automatically read by Claude Code to govern behaviour in this project:

```markdown
# Juntos — Claude Code Usage Rules

## Non-negotiable
- Always use Ash Framework for all data access. Never use raw Ecto queries.
- Every new Ash resource must declare both `sqlite` and `postgres` data layer blocks.
- All business logic lives in Ash actions and changes — not in LiveView callbacks.
- LiveView callbacks only call Ash actions or read from assigns.
- Tests must be written for every feature, targeting ~80% coverage.
- Never commit secrets. Use `System.fetch_env!/1` in prod config.
- Follow all Elixir anti-pattern guidance (see Section 11).

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
```

### 7.2 `.claude/agents.md`

```markdown
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
```

---

## 8. live_svelte Setup

### 8.1 Install

```bash
cd assets && npm install live_svelte
```

Add to `assets/js/app.js`:

```javascript
import { SvelteAdapter } from "live_svelte"
import * as Components from "../svelte/**/*.svelte"

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: SvelteAdapter.hooks(Components),
  params: { _csrf_token: csrfToken }
})
```

### 8.2 Svelte Component Convention

```
assets/svelte/
  components/
    Button.svelte
    Modal.svelte
  features/
    <feature_name>/
      <ComponentName>.svelte
```

### 8.3 Using in LiveView

```elixir
# In a LiveView template
<.svelte name="components/Button" props={%{label: "Click me", disabled: false}} />
```

### 8.4 Svelte Testing

Use Vitest for unit tests on Svelte components:

```bash
cd assets && npm install -D vitest @testing-library/svelte @testing-library/jest-dom jsdom
```

`assets/vitest.config.js`:

```javascript
import { defineConfig } from 'vitest/config'
import { svelte } from '@sveltejs/vite-plugin-svelte'

export default defineConfig({
  plugins: [svelte({ hot: !process.env.VITEST })],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './test/setup.js'
  }
})
```

---

## 9. Oban Configuration

Add to `config/config.exs` (activated only when a worker is introduced):

```elixir
config :juntos, Oban,
  repo: Juntos.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, mailers: 5]
```

Use `AshOban` to wire Oban workers to Ash actions:

```elixir
defmodule Juntos.Workers.SomeWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    # Call Ash action here, not raw business logic
    Juntos.Core.SomeResource
    |> Ash.get!(args["id"])
    |> Ash.Changeset.for_update(:process, %{})
    |> Ash.update!()

    :ok
  end
end
```

---

## 10. GitHub Actions CI

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

env:
  MIX_ENV: test
  ELIXIR_VERSION: "1.16"
  OTP_VERSION: "26"

jobs:
  test:
    name: Build & Test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up Elixir
        uses: erlef/setup-beam@v1
        with:
          elixir-version: ${{ env.ELIXIR_VERSION }}
          otp-version: ${{ env.OTP_VERSION }}

      - name: Restore deps cache
        uses: actions/cache@v4
        with:
          path: deps
          key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
          restore-keys: ${{ runner.os }}-mix-

      - name: Restore build cache
        uses: actions/cache@v4
        with:
          path: _build
          key: ${{ runner.os }}-build-${{ hashFiles('**/mix.lock') }}
          restore-keys: ${{ runner.os }}-build-

      - name: Install dependencies
        run: mix deps.get

      - name: Compile (warnings as errors)
        run: mix compile --warnings-as-errors

      - name: Check formatting
        run: mix format --check-formatted

      - name: Run Elixir tests
        run: mix test --cover

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
          cache-dependency-path: assets/package-lock.json

      - name: Install JS dependencies
        run: cd assets && npm ci

      - name: Run JS/Svelte tests
        run: cd assets && npm run test

  credo:
    name: Credo (static analysis)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: erlef/setup-beam@v1
        with:
          elixir-version: ${{ env.ELIXIR_VERSION }}
          otp-version: ${{ env.OTP_VERSION }}
      - run: mix deps.get
      - run: mix credo --strict
```

Add `credo` to `mix.exs` deps:

```elixir
{:credo, "~> 1.7", only: [:dev, :test], runtime: false},
```

---

## 11. Anti-Pattern Guard Rules

These are derived from the official Elixir anti-pattern guides and must be checked on every code review and agent generation pass.

### Code Anti-Patterns

| Anti-pattern | What to do instead |
|---|---|
| `Enum.map` + `Enum.filter` chained | Use `Enum.flat_map` or comprehensions |
| `length(list) == 0` | Use `list == []` or `match?([_ | _], list)` |
| Unnecessary `Enum.count` | Use pattern matching |
| Deeply nested `case`/`with` | Extract named functions |
| `String.to_atom/1` on user input | Use `String.to_existing_atom/1` or pattern match |
| Large anonymous functions | Extract to named private functions |
| `try/rescue` for control flow | Use `{:ok, _}` / `{:error, _}` tuples |

### Design Anti-Patterns

| Anti-pattern | What to do instead |
|---|---|
| God modules | Keep modules focused on a single responsibility |
| Reaching into other domain internals | Only call public domain API (Ash actions) |
| Structs with optional fields overloaded as discriminated unions | Use tagged tuples or separate structs |
| Passing large maps where structs suffice | Define Ash attributes with types |
| Primitive obsession (raw strings for emails, IDs) | Use Ash custom types or Ecto `Parameterized.Type` |

### Process Anti-Patterns

| Anti-pattern | What to do instead |
|---|---|
| Using processes for code organisation | Only use processes when genuinely needed (state, concurrency, isolation) |
| Sending messages to `self()` for deferred work | Use function calls; Oban for actual deferral |
| Registering atoms dynamically from user data | Use a registry with string keys |
| GenServer that owns all business logic | Keep business logic in Ash actions; GenServer only manages state/lifecycle |

### Macro Anti-Patterns

| Anti-pattern | What to do instead |
|---|---|
| Macros that could be functions | Write a regular function |
| Macros injecting large hidden code | Prefer explicit calls and `use` with clear `__using__` docs |
| `@before_compile` with side effects | Prefer `defmacro` with explicit call sites |

### What-Anti-Patterns (general)

- Never rescue `Exception` broadly — match specific errors
- Never use `throw`/`catch` for control flow
- Avoid deep pipeline chains where intermediate values are not self-documenting — use `with` or named bindings
- Do not use `Process.put/get` (process dictionary) except when interfacing with external libraries that require it

---

## 12. Testing Strategy

### Elixir Tests

- **Unit**: Test every Ash action in isolation using `Ash.Test` helpers
- **Integration**: Phoenix LiveView tests using `Phoenix.LiveViewTest`
- **Factory**: All test data created via `ex_machina` factories in `test/support/factory.ex`
- **Mocks**: External HTTP calls mocked with `bypass` or `mox` — never reach real endpoints
- **Coverage target**: ~80% (tracked but not enforced as hard gate in CI)

```elixir
# Example Ash action test
defmodule Juntos.Accounts.UserTest do
  use Juntos.DataCase

  test "creates user with valid attrs" do
    assert {:ok, user} =
      Ash.create(Juntos.Accounts.User, %{email: "test@example.com"})

    assert user.email == "test@example.com"
  end
end
```

### JavaScript / Svelte Tests

- Vitest for unit tests on Svelte components
- `@testing-library/svelte` for component rendering tests
- Target ~80% coverage on components that have logic
- Run via `npm run test` in the `assets/` directory

---

## 13. Project File Structure (Target)

```
juntos/
├── .claude/
│   ├── mcp.json
│   ├── usage_rules.md
│   └── agents.md
├── .github/
│   └── workflows/
│       └── ci.yml
├── assets/
│   ├── svelte/
│   │   ├── components/
│   │   └── features/
│   ├── js/
│   │   └── app.js
│   ├── test/
│   └── vitest.config.js
├── config/
│   ├── config.exs
│   ├── dev.exs
│   ├── test.exs
│   ├── prod.exs
│   └── runtime.exs
├── lib/
│   ├── juntos/
│   │   ├── accounts/
│   │   │   ├── accounts.ex
│   │   │   ├── user.ex
│   │   │   └── token.ex
│   │   ├── core/             # feature domains added here
│   │   └── repo.ex
│   └── juntos_web/
│       ├── components/
│       ├── live/
│       ├── router.ex
│       └── endpoint.ex
├── priv/
│   └── repo/
│       └── migrations/
├── test/
│   ├── support/
│   │   ├── factory.ex
│   │   ├── data_case.ex
│   │   └── conn_case.ex
│   ├── juntos/
│   └── juntos_web/
├── mix.exs
├── mix.lock
└── JUNTOS_PROJECT_SETUP.md   ← this file
```

---

## 14. Initial Setup Checklist (run in order)

```
[ ] mix igniter.new juntos --with phx.new ...
[ ] Add all deps to mix.exs
[ ] mix deps.get
[ ] Configure dev/test/prod database adapters
[ ] mix ash.gen.domain Juntos.Accounts
[ ] mix ash.gen.resource Juntos.Accounts.User
[ ] mix ash.generate_migrations && mix ecto.migrate
[ ] Configure live_svelte in assets/js/app.js
[ ] Add Tidewave and AshAi.Mcp.Dev to endpoint
[ ] Create .claude/mcp.json, usage_rules.md, agents.md
[ ] Create .github/workflows/ci.yml
[ ] mix igniter.install ash_authentication --auth-strategy password
[ ] mix ash_ai.gen.mcp
[ ] git init && git remote add origin <repo>
[ ] git push -u origin main
[ ] Verify GitHub Actions runs green
```

---

## 15. Key Reference Links

- Ash Framework: https://ash-hq.org
- AshAi / MCP: https://hexdocs.pm/ash_ai/readme.html
- Tidewave: https://tidewave.ai
- live_svelte: https://github.com/woutdp/live_svelte
- Oban: https://obanpro.com/docs/oban/v2/readme
- Elixir Anti-Patterns:
  - https://hexdocs.pm/elixir/what-anti-patterns.html
  - https://hexdocs.pm/elixir/code-anti-patterns.html
  - https://hexdocs.pm/elixir/design-anti-patterns.html
  - https://hexdocs.pm/elixir/process-anti-patterns.html
  - https://hexdocs.pm/elixir/macro-anti-patterns.html

---

*Last updated: March 2026 — share this document with Claude Code at the start of every session.*
