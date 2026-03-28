This is a web application written using the Phoenix web framework.

## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps

### Phoenix v1.8 guidelines

- **Always** begin your LiveView templates with `<Layouts.app flash={@flash} ...>` which wraps all inner content
- The `MyAppWeb.Layouts` module is aliased in the `my_app_web.ex` file, so you can use it without needing to alias it again
- Anytime you run into errors with no `current_scope` assign:
  - You failed to follow the Authenticated Routes guidelines, or you failed to pass `current_scope` to `<Layouts.app>`
  - **Always** fix the `current_scope` error by moving your routes to the proper `live_session` and ensure you pass `current_scope` as needed
- Phoenix v1.8 moved the `<.flash_group>` component to the `Layouts` module. You are **forbidden** from calling `<.flash_group>` outside of the `layouts.ex` module
- Out of the box, `core_components.ex` imports an `<.icon name="hero-x-mark" class="w-5 h-5"/>` component for hero icons. **Always** use the `<.icon>` component for icons, **never** use `Heroicons` modules or similar
- **Always** use the imported `<.input>` component for form inputs from `core_components.ex` when available. `<.input>` is imported and using it will save steps and prevent errors
- If you override the default input classes (`<.input class="myclass px-2 py-1 rounded-lg">)`) class with your own values, no default classes are inherited, so your
custom classes must fully style the input

### JS and CSS guidelines

- **Use Tailwind CSS classes and custom CSS rules** to create polished, responsive, and visually stunning interfaces.
- Tailwindcss v4 **no longer needs a tailwind.config.js** and uses a new import syntax in `app.css`:

      @import "tailwindcss" source(none);
      @source "../css";
      @source "../js";
      @source "../../lib/my_app_web";

- **Always use and maintain this import syntax** in the app.css file for projects generated with `phx.new`
- **Never** use `@apply` when writing raw css
- **Always** manually write your own tailwind-based components instead of using daisyUI for a unique, world-class design
- Out of the box **only the app.js and app.css bundles are supported**
  - You cannot reference an external vendor'd script `src` or link `href` in the layouts
  - You must import the vendor deps into app.js and app.css to use them
  - **Never write inline <script>custom js</script> tags within templates**

### UI/UX & design guidelines

- **Produce world-class UI designs** with a focus on usability, aesthetics, and modern design principles
- Implement **subtle micro-interactions** (e.g., button hover effects, and smooth transitions)
- Ensure **clean typography, spacing, and layout balance** for a refined, premium look
- Focus on **delightful details** like hover effects, loading states, and smooth page transitions

<!-- usage-rules-start -->

<!-- phoenix:elixir-start -->
## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason

## Test guidelines

- **Always use `start_supervised!/1`** to start processes in tests as it guarantees cleanup between tests
- **Avoid** `Process.sleep/1` and `Process.alive?/1` in tests
  - Instead of sleeping to wait for a process to finish, **always** use `Process.monitor/1` and assert on the DOWN message:

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

  - Instead of sleeping to synchronize before the next call, **always** use `_ = :sys.get_state/1` to ensure the process has handled prior messages
<!-- phoenix:elixir-end -->

<!-- phoenix:phoenix-start -->
## Phoenix guidelines

- Remember Phoenix router `scope` blocks include an optional alias which is prefixed for all routes within the scope. **Always** be mindful of this when creating routes within a scope to avoid duplicate module prefixes.

- You **never** need to create your own `alias` for route definitions! The `scope` provides the alias, ie:

      scope "/admin", AppWeb.Admin do
        pipe_through :browser

        live "/users", UserLive, :index
      end

  the UserLive route would point to the `AppWeb.Admin.UserLive` module

- `Phoenix.View` no longer is needed or included with Phoenix, don't use it
<!-- phoenix:phoenix-end -->

<!-- phoenix:ecto-start -->
## Ecto Guidelines

- **Always** preload Ecto associations in queries when they'll be accessed in templates, ie a message that needs to reference the `message.user.email`
- Remember `import Ecto.Query` and other supporting modules when you write `seeds.exs`
- `Ecto.Schema` fields always use the `:string` type, even for `:text`, columns, ie: `field :name, :string`
- `Ecto.Changeset.validate_number/2` **DOES NOT SUPPORT the `:allow_nil` option**. By default, Ecto validations only run if a change for the given field exists and the change value is not nil, so such as option is never needed
- You **must** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields which are set programmatically, such as `user_id`, must not be listed in `cast` calls or similar for security purposes. Instead they must be explicitly set when creating the struct
- **Always** invoke `mix ecto.gen.migration migration_name_using_underscores` when generating migration files, so the correct timestamp and conventions are applied
<!-- phoenix:ecto-end -->

<!-- phoenix:html-start -->
## Phoenix HTML guidelines

- Phoenix templates **always** use `~H` or .html.heex files (known as HEEx), **never** use `~E`
- **Always** use the imported `Phoenix.Component.form/1` and `Phoenix.Component.inputs_for/1` function to build forms. **Never** use `Phoenix.HTML.form_for` or `Phoenix.HTML.inputs_for` as they are outdated
- When building forms **always** use the already imported `Phoenix.Component.to_form/2` (`assign(socket, form: to_form(...))` and `<.form for={@form} id="msg-form">`), then access those forms in the template via `@form[:field]`
- **Always** add unique DOM IDs to key elements (like forms, buttons, etc) when writing templates, these IDs can later be used in tests (`<.form for={@form} id="product-form">`)
- For "app wide" template imports, you can import/alias into the `my_app_web.ex`'s `html_helpers` block, so they will be available to all LiveViews, LiveComponent's, and all modules that do `use MyAppWeb, :html` (replace "my_app" by the actual app name)

- Elixir supports `if/else` but **does NOT support `if/else if` or `if/elsif`**. **Never use `else if` or `elseif` in Elixir**, **always** use `cond` or `case` for multiple conditionals.

  **Never do this (invalid)**:

      <%= if condition do %>
        ...
      <% else if other_condition %>
        ...
      <% end %>

  Instead **always** do this:

      <%= cond do %>
        <% condition -> %>
          ...
        <% condition2 -> %>
          ...
        <% true -> %>
          ...
      <% end %>

- HEEx require special tag annotation if you want to insert literal curly's like `{` or `}`. If you want to show a textual code snippet on the page in a `<pre>` or `<code>` block you *must* annotate the parent tag with `phx-no-curly-interpolation`:

      <code phx-no-curly-interpolation>
        let obj = {key: "val"}
      </code>

  Within `phx-no-curly-interpolation` annotated tags, you can use `{` and `}` without escaping them, and dynamic Elixir expressions can still be used with `<%= ... %>` syntax

- HEEx class attrs support lists, but you must **always** use list `[...]` syntax. You can use the class list syntax to conditionally add classes, **always do this for multiple class values**:

      <a class={[
        "px-2 text-white",
        @some_flag && "py-5",
        if(@other_condition, do: "border-red-500", else: "border-blue-100"),
        ...
      ]}>Text</a>

  and **always** wrap `if`'s inside `{...}` expressions with parens, like done above (`if(@other_condition, do: "...", else: "...")`)

  and **never** do this, since it's invalid (note the missing `[` and `]`):

      <a class={
        "px-2 text-white",
        @some_flag && "py-5"
      }> ...
      => Raises compile syntax error on invalid HEEx attr syntax

- **Never** use `<% Enum.each %>` or non-for comprehensions for generating template content, instead **always** use `<%= for item <- @collection do %>`
- HEEx HTML comments use `<%!-- comment --%>`. **Always** use the HEEx HTML comment syntax for template comments (`<%!-- comment --%>`)
- HEEx allows interpolation via `{...}` and `<%= ... %>`, but the `<%= %>` **only** works within tag bodies. **Always** use the `{...}` syntax for interpolation within tag attributes, and for interpolation of values within tag bodies. **Always** interpolate block constructs (if, cond, case, for) within tag bodies using `<%= ... %>`.

  **Always** do this:

      <div id={@id}>
        {@my_assign}
        <%= if @some_block_condition do %>
          {@another_assign}
        <% end %>
      </div>

  and **Never** do this – the program will terminate with a syntax error:

      <%!-- THIS IS INVALID NEVER EVER DO THIS --%>
      <div id="<%= @invalid_interpolation %>">
        {if @invalid_block_construct do}
        {end}
      </div>
<!-- phoenix:html-end -->

<!-- phoenix:liveview-start -->
## Phoenix LiveView guidelines

- **Never** use the deprecated `live_redirect` and `live_patch` functions, instead **always** use the `<.link navigate={href}>` and  `<.link patch={href}>` in templates, and `push_navigate` and `push_patch` functions LiveViews
- **Avoid LiveComponent's** unless you have a strong, specific need for them
- LiveViews should be named like `AppWeb.WeatherLive`, with a `Live` suffix. When you go to add LiveView routes to the router, the default `:browser` scope is **already aliased** with the `AppWeb` module, so you can just do `live "/weather", WeatherLive`

### LiveView streams

- **Always** use LiveView streams for collections for assigning regular lists to avoid memory ballooning and runtime termination with the following operations:
  - basic append of N items - `stream(socket, :messages, [new_msg])`
  - resetting stream with new items - `stream(socket, :messages, [new_msg], reset: true)` (e.g. for filtering items)
  - prepend to stream - `stream(socket, :messages, [new_msg], at: -1)`
  - deleting items - `stream_delete(socket, :messages, msg)`

- When using the `stream/3` interfaces in the LiveView, the LiveView template must 1) always set `phx-update="stream"` on the parent element, with a DOM id on the parent element like `id="messages"` and 2) consume the `@streams.stream_name` collection and use the id as the DOM id for each child. For a call like `stream(socket, :messages, [new_msg])` in the LiveView, the template would be:

      <div id="messages" phx-update="stream">
        <div :for={{id, msg} <- @streams.messages} id={id}>
          {msg.text}
        </div>
      </div>

- LiveView streams are *not* enumerable, so you cannot use `Enum.filter/2` or `Enum.reject/2` on them. Instead, if you want to filter, prune, or refresh a list of items on the UI, you **must refetch the data and re-stream the entire stream collection, passing reset: true**:

      def handle_event("filter", %{"filter" => filter}, socket) do
        # re-fetch the messages based on the filter
        messages = list_messages(filter)

        {:noreply,
         socket
         |> assign(:messages_empty?, messages == [])
         # reset the stream with the new messages
         |> stream(:messages, messages, reset: true)}
      end

- LiveView streams *do not support counting or empty states*. If you need to display a count, you must track it using a separate assign. For empty states, you can use Tailwind classes:

      <div id="tasks" phx-update="stream">
        <div class="hidden only:block">No tasks yet</div>
        <div :for={{id, task} <- @streams.tasks} id={id}>
          {task.name}
        </div>
      </div>

  The above only works if the empty state is the only HTML block alongside the stream for-comprehension.

- When updating an assign that should change content inside any streamed item(s), you MUST re-stream the items
  along with the updated assign:

      def handle_event("edit_message", %{"message_id" => message_id}, socket) do
        message = Chat.get_message!(message_id)
        edit_form = to_form(Chat.change_message(message, %{content: message.content}))

        # re-insert message so @editing_message_id toggle logic takes effect for that stream item
        {:noreply,
         socket
         |> stream_insert(:messages, message)
         |> assign(:editing_message_id, String.to_integer(message_id))
         |> assign(:edit_form, edit_form)}
      end

  And in the template:

      <div id="messages" phx-update="stream">
        <div :for={{id, message} <- @streams.messages} id={id} class="flex group">
          {message.username}
          <%= if @editing_message_id == message.id do %>
            <%!-- Edit mode --%>
            <.form for={@edit_form} id="edit-form-#{message.id}" phx-submit="save_edit">
              ...
            </.form>
          <% end %>
        </div>
      </div>

- **Never** use the deprecated `phx-update="append"` or `phx-update="prepend"` for collections

### LiveView JavaScript interop

- Remember anytime you use `phx-hook="MyHook"` and that JS hook manages its own DOM, you **must** also set the `phx-update="ignore"` attribute
- **Always** provide an unique DOM id alongside `phx-hook` otherwise a compiler error will be raised

LiveView hooks come in two flavors, 1) colocated js hooks for "inline" scripts defined inside HEEx,
and 2) external `phx-hook` annotations where JavaScript object literals are defined and passed to the `LiveSocket` constructor.

#### Inline colocated js hooks

**Never** write raw embedded `<script>` tags in heex as they are incompatible with LiveView.
Instead, **always use a colocated js hook script tag (`:type={Phoenix.LiveView.ColocatedHook}`)
when writing scripts inside the template**:

    <input type="text" name="user[phone_number]" id="user-phone-number" phx-hook=".PhoneNumber" />
    <script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
      export default {
        mounted() {
          this.el.addEventListener("input", e => {
            let match = this.el.value.replace(/\D/g, "").match(/^(\d{3})(\d{3})(\d{4})$/)
            if(match) {
              this.el.value = `${match[1]}-${match[2]}-${match[3]}`
            }
          })
        }
      }
    </script>

- colocated hooks are automatically integrated into the app.js bundle
- colocated hooks names **MUST ALWAYS** start with a `.` prefix, i.e. `.PhoneNumber`

#### External phx-hook

External JS hooks (`<div id="myhook" phx-hook="MyHook">`) must be placed in `assets/js/` and passed to the
LiveSocket constructor:

    const MyHook = {
      mounted() { ... }
    }
    let liveSocket = new LiveSocket("/live", Socket, {
      hooks: { MyHook }
    });

#### Pushing events between client and server

Use LiveView's `push_event/3` when you need to push events/data to the client for a phx-hook to handle.
**Always** return or rebind the socket on `push_event/3` when pushing events:

    # re-bind socket so we maintain event state to be pushed
    socket = push_event(socket, "my_event", %{...})

    # or return the modified socket directly:
    def handle_event("some_event", _, socket) do
      {:noreply, push_event(socket, "my_event", %{...})}
    end

Pushed events can then be picked up in a JS hook with `this.handleEvent`:

    mounted() {
      this.handleEvent("my_event", data => console.log("from server:", data));
    }

Clients can also push an event to the server and receive a reply with `this.pushEvent`:

    mounted() {
      this.el.addEventListener("click", e => {
        this.pushEvent("my_event", { one: 1 }, reply => console.log("got reply from server:", reply));
      })
    }

Where the server handled it via:

    def handle_event("my_event", %{"one" => 1}, socket) do
      {:reply, %{two: 2}, socket}
    end

### LiveView tests

- `Phoenix.LiveViewTest` module and `LazyHTML` (included) for making your assertions
- Form tests are driven by `Phoenix.LiveViewTest`'s `render_submit/2` and `render_change/2` functions
- Come up with a step-by-step test plan that splits major test cases into small, isolated files. You may start with simpler tests that verify content exists, gradually add interaction tests
- **Always reference the key element IDs you added in the LiveView templates in your tests** for `Phoenix.LiveViewTest` functions like `element/2`, `has_element/2`, selectors, etc
- **Never** tests again raw HTML, **always** use `element/2`, `has_element/2`, and similar: `assert has_element?(view, "#my-form")`
- Instead of relying on testing text content, which can change, favor testing for the presence of key elements
- Focus on testing outcomes rather than implementation details
- Be aware that `Phoenix.Component` functions like `<.form>` might produce different HTML than expected. Test against the output HTML structure, not your mental model of what you expect it to be
- When facing test failures with element selectors, add debug statements to print the actual HTML, but use `LazyHTML` selectors to limit the output, ie:

      html = render(view)
      document = LazyHTML.from_fragment(html)
      matches = LazyHTML.filter(document, "your-complex-selector")
      IO.inspect(matches, label: "Matches")

### Form handling

#### Creating a form from params

If you want to create a form based on `handle_event` params:

    def handle_event("submitted", params, socket) do
      {:noreply, assign(socket, form: to_form(params))}
    end

When you pass a map to `to_form/1`, it assumes said map contains the form params, which are expected to have string keys.

You can also specify a name to nest the params:

    def handle_event("submitted", %{"user" => user_params}, socket) do
      {:noreply, assign(socket, form: to_form(user_params, as: :user))}
    end

#### Creating a form from changesets

When using changesets, the underlying data, form params, and errors are retrieved from it. The `:as` option is automatically computed too. E.g. if you have a user schema:

    defmodule MyApp.Users.User do
      use Ecto.Schema
      ...
    end

And then you create a changeset that you pass to `to_form`:

    %MyApp.Users.User{}
    |> Ecto.Changeset.change()
    |> to_form()

Once the form is submitted, the params will be available under `%{"user" => user_params}`.

In the template, the form form assign can be passed to the `<.form>` function component:

    <.form for={@form} id="todo-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:field]} type="text" />
    </.form>

Always give the form an explicit, unique DOM ID, like `id="todo-form"`.

#### Avoiding form errors

**Always** use a form assigned via `to_form/2` in the LiveView, and the `<.input>` component in the template. In the template **always access forms this**:

    <%!-- ALWAYS do this (valid) --%>
    <.form for={@form} id="my-form">
      <.input field={@form[:field]} type="text" />
    </.form>

And **never** do this:

    <%!-- NEVER do this (invalid) --%>
    <.form for={@changeset} id="my-form">
      <.input field={@changeset[:field]} type="text" />
    </.form>

- You are FORBIDDEN from accessing the changeset in the template as it will cause errors
- **Never** use `<.form let={f} ...>` in the template, instead **always use `<.form for={@form} ...>`**, then drive all form references from the form assign as in `@form[:field]`. The UI should **always** be driven by a `to_form/2` assigned in the LiveView module that is derived from a changeset
<!-- phoenix:liveview-end -->

<!-- juntos:tech-guide-start -->

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

> Note: We manage the Ecto adapter manually (PostgreSQL in dev/test, PostgresSQL in prod) so skip the default generator's Ecto flags and configure manually.

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

### E2E / Happy-path tests (mandatory)
Every happy-path and critical-path user flow **must** have an E2E test using `phoenix_test_playwright`.
This is the only way to test flows that span both the Phoenix LiveView layer and Svelte components,
since Svelte runs in the browser and is invisible to `Phoenix.LiveViewTest`.

**When to write an E2E test (required):**
- Any user-facing flow that involves a Svelte component (forms, buttons, interactions)
- Authentication and sign-out flows
- Any action that changes persistent state a user would immediately see (create, delete, publish)

**Setup:**
- All E2E tests live in `test/e2e/` and use `JuntosWeb.E2ECase`
- Tag every E2E test with `@tag :e2e`
- Run only E2E tests: `mix test --only e2e`
- Exclude E2E from fast unit runs: `mix test --exclude e2e`
- Install browser once per machine: `cd assets && npx playwright install chromium --with-deps`

**Writing E2E tests:**
```elixir
defmodule JuntosWeb.E2E.MyFlowTest do
  use JuntosWeb.E2ECase   # wraps PhoenixTest.Playwright.Case

  setup %{conn: conn} do
    user = create_user()
    conn = log_in_user(conn, user)   # injects a signed session cookie
    {:ok, conn: conn, user: user}
  end

  @tag :e2e
  test "user can complete the flow", %{conn: conn} do
    conn
    |> visit(~p"/some-path")
    |> fill_in("Label", with: "value")
    |> click_button("Submit")
    |> assert_has("p", text: "Success")
  end
end
```

**Key helpers (from `JuntosWeb.E2ECase`):**

- `log_in_user(conn, user)` — injects authenticated session cookie into browser context
- `create_user/0,1` — creates a user via `Ash.Seed` (no email sent)
- `create_conference/2` — creates a conference owned by a user

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

All `.svelte` files live flat in `assets/svelte/` (no subdirectories — `use LiveSvelte.Components`
only scans `assets/svelte/*.svelte`):

```
assets/svelte/
  ConferenceDashboard.svelte
  ConferenceTickets.svelte
  TicTacToe.svelte
```

### 8.3 Using in LiveView — Two Patterns

#### Pattern 1: `use LiveSvelte.Components` (preferred for separate .svelte files)

Generates a named component function for every `.svelte` file in `assets/svelte/*.svelte`.
Props are whatever attributes you pass explicitly; the Svelte side receives `live` automatically.

```elixir
defmodule MyAppWeb.ExampleLive do
  use MyAppWeb, :live_view
  use LiveSvelte.Components          # generates <.MyComponent .../>

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("inc", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <.MyComponent count={@count} socket={@socket} />
    """
  end
end
```

```svelte
<!-- assets/svelte/MyComponent.svelte -->
<script>
  let { count = 0, live } = $props();
  function inc() { live.pushEvent("inc", {}); }
</script>
<button onclick={inc}>Count: {count}</button>
```

#### Pattern 2: `~V` sigil (inline Svelte, no separate file)

Writes the Svelte code to `assets/svelte/_build/<Module>.svelte` at compile time.
**All assigns** (excluding reserved keys) become props automatically via `get_props(assigns)`.
Use for small, tightly-coupled components that don't need a separate file.
**Only one `~V` per module** (would overwrite the same generated file).

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view
  import LiveSvelte            # needed for ~V and get_props/get_socket helpers

  def mount(_params, _session, socket), do: {:ok, assign(socket, count: 0)}

  def handle_event("inc", _, socket), do: {:noreply, update(socket, :count, &(&1 + 1))}

  def render(assigns) do
    ~V"""
    <script>
      let { count = 0, live } = $props();
    </script>
    <button onclick={() => live.pushEvent("inc", {})}>Count: {count}</button>
    """
  end
end
```

#### ❌ Avoid — manual `<.svelte name=...>` (old API)

```elixir
# Do NOT do this — use Pattern 1 instead
<.svelte name="MyComponent" props={%{count: @count}} socket={@socket} />
```

### 8.3a Svelte 5 Runes Best Practices in live_svelte

- **Always use Svelte 5 runes** (`$props()`, `$state()`, `$derived()`) — never legacy `export let` or `$:` syntax
- **`live` prop is injected automatically** by live_svelte — always destructure it: `let { ..., live } = $props()`
- **Props must be JSON-serializable** — convert Ash structs, atoms, and DateTimes on the Elixir side before assigning
- **Use `$state.raw()`** for large arrays/objects that are only ever reassigned (not mutated item-by-item) — avoids proxy overhead
- **Keep Svelte state local** — only send events to the server when the server needs to know (avoid round-trips for pure UI state like `showForm`)
- **Use keyed `{#each}` blocks** — always key by a stable ID, never by index

```svelte
<script>
  // Conferences come from LiveView — use $state.raw since we only ever reassign the whole array
  let { conferences = [], live } = $props();
  let conferenceList = $state.raw(conferences);

  // Local UI state uses $state (fine for small values)
  let showForm = $state(false);

  // Update local state when props change
  $effect(() => { conferenceList = conferences; });
</script>

{#each conferenceList as c (c.id)}
  ...
{/each}
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

### 8.4a LiveView Testing Rules

**Every LiveView module must have a corresponding `_test.exs` file.** No exceptions.

#### Setup: ConnCase helpers

`test/support/conn_case.ex` provides:

```elixir
# Create a user (bypasses auth strategy — no email sent)
user = create_user()
user = create_user(%{email: "specific@example.com"})

# Log a user into the conn (stores a valid JWT in the Phoenix session)
conn = log_in_user(conn, user)

# Create a conference owned by a user
conf = create_conference(user, %{name: "ElixirConf", location: "Austin"})
```

#### Pattern

```elixir
defmodule MyAppWeb.SomeLiveTest do
  use JuntosWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  # Unauthenticated access guard — always test this for protected routes
  test "redirects unauthenticated users to sign-in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/sign-in"}}} = live(conn, ~p"/dashboard")
  end

  # Authenticated test
  test "renders the page", %{conn: conn} do
    user = create_user()
    conn = log_in_user(conn, user)
    {:ok, _view, html} = live(conn, ~p"/dashboard")
    assert html =~ "expected content"
  end

  # Test handle_event
  test "handles an event", %{conn: conn} do
    user = create_user()
    conn = log_in_user(conn, user)
    {:ok, view, _html} = live(conn, ~p"/dashboard")

    render_hook(view, "my_event", %{"key" => "value"})

    assert render(view) =~ "expected result"
  end
end
```

#### What to test in LiveView tests

- Redirect for unauthenticated access (all protected routes)
- `mount/3`: page renders with correct initial data
- Each `handle_event/3`: state changes and HTML updates
- Authorization: user cannot act on another user's data
- Edge cases: not found redirects, empty states

#### What NOT to test in LiveView tests

- Svelte component rendering (that's for Vitest/`@testing-library/svelte`)
- CSS classes / visual styling
- Client-side-only interactions (those stay in JS tests)

When a LiveView uses `<.ConferenceTickets ...>`, test that the Svelte **mount point** is present
in HTML (`assert html =~ "ConferenceTickets"`), not the rendered ticket HTML (client-only).

---

### 8.5 Svelte Component Testing Rules

**Every Svelte component in `assets/svelte/` must have a test in `assets/test/<Name>.test.js`.**

Use Vitest + `@testing-library/svelte`. Run with `cd assets && npm test`.

#### Pattern

```javascript
import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/svelte";
import MyComponent from "../svelte/MyComponent.svelte";

// Always mock `live` — never use a real LiveView socket in JS tests
function mockLive() {
  return { pushEvent: vi.fn() };
}

describe("MyComponent", () => {
  it("renders the expected content", () => {
    render(MyComponent, { props: { count: 5, live: mockLive() } });
    expect(screen.getByText("5")).toBeInTheDocument();
  });

  it("calls pushEvent on interaction", async () => {
    const live = mockLive();
    render(MyComponent, { props: { count: 0, live } });
    await fireEvent.click(screen.getByRole("button", { name: /increment/i }));
    expect(live.pushEvent).toHaveBeenCalledWith("inc", {});
  });
});
```

#### What to test in Svelte tests

- Rendering: correct text, labels, counts, status badges
- Conditional rendering: elements shown/hidden based on props
- User interactions: clicks and form submissions call the right `live.pushEvent`
- Props → display logic (price formatting, status labels, etc.)
- Edge cases: empty arrays, null values, zero counts

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

This should pass in local before committing

```
mix test --cover --exclude e2e
```

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

- Ash Framework: <https://ash-hq.org>
- AshAi / MCP: <https://hexdocs.pm/ash_ai/readme.html>
- Tidewave: <https://tidewave.ai>
- live_svelte: <https://github.com/woutdp/live_svelte>
- Oban: <https://obanpro.com/docs/oban/v2/readme>
- Elixir Anti-Patterns:
  - <https://hexdocs.pm/elixir/what-anti-patterns.html>
  - <https://hexdocs.pm/elixir/code-anti-patterns.html>
  - <https://hexdocs.pm/elixir/design-anti-patterns.html>
  - <https://hexdocs.pm/elixir/process-anti-patterns.html>
  - <https://hexdocs.pm/elixir/macro-anti-patterns.html>

---

<!-- juntos:tech-guide-end -->
<!-- usage-rules-end -->
