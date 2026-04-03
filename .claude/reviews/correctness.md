## Correctness & Style Review

### Critical Issues (Must Fix)

1. **ConferenceLive: Database query in disconnected mount** (Iron Law violation)
   - File: `lib/juntos_web/live/conference_live.ex:7-21`
   - The `mount/3` calls `load_conference(slug)` unconditionally, including during disconnected mount. This fires a database query before the WebSocket is even connected, doubling the query load. DashboardLive correctly checks `connected?(socket)` before querying, but ConferenceLive does not.
   - Fix: Return minimal assigns in disconnected mount, load data only when `connected?(socket)`.

2. **ConferenceLive: Missing `@impl true` annotations**
   - File: `lib/juntos_web/live/conference_live.ex:7,24,55`
   - `mount/3`, `handle_event/3`, and `render/1` lack `@impl true`. DashboardLive has the same issue. TictactoeLive correctly uses `@impl true` on all callbacks. This is inconsistent and means the compiler cannot catch typos in callback names.

3. **DashboardLive: Missing `@impl true` annotations**
   - File: `lib/juntos_web/live/dashboard_live.ex:8,24,55,129`
   - Same issue as ConferenceLive.

### Warnings (Should Fix)

1. **DashboardLive: `Ash.destroy!` without error handling in delete_conference**
   - File: `lib/juntos_web/live/dashboard_live.ex:63`
   - `Ash.destroy!(conference)` will raise on failure (e.g., foreign key constraint). The create path handles errors gracefully, but the destroy path crashes the LiveView process. Use `Ash.destroy/1` with pattern matching instead.

2. **DashboardLive: `Ash.read!` in load_conferences can crash**
   - File: `lib/juntos_web/live/dashboard_live.ex:88`
   - If the Ash read fails for any reason (e.g., connection timeout), the LiveView process crashes. Use `Ash.read/1` and handle the error tuple.

3. **ConferenceLive: Missing catch-all for `status_classes/1` and `status_label/1`**
   - File: `lib/juntos_web/live/conference_live.ex:103-122`
   - If a new status atom is added to the Conference schema, these functions will crash with `FunctionClauseError`. Add a catch-all clause or use a default.

4. **DashboardLive: `build_slug/1` does not guarantee uniqueness**
   - File: `lib/juntos_web/live/dashboard_live.ex:114-127`
   - Two conferences named "ElixirConf" would get the same slug "elixirconf". The Ash identity `unique_slug` would catch this at the DB level, but the user gets a cryptic Ash error. Consider appending a random suffix or handling the unique constraint error with a user-friendly message.

5. **TictactoeLive: `String.to_integer("#{index}")` is redundant**
   - File: `lib/juntos_web/live/tictactoe_live.ex:22`
   - The string interpolation `"#{index}"` is unnecessary since `index` from event params is already a string. Use `String.to_integer(index)` directly.

### Style Suggestions

1. **Inconsistent `require Ash.Query`**: DashboardLive has `require Ash.Query` (line 4) but ConferenceLive does not, even though both use `Ash.Query`. This works because `Ash.Query.for_read/2` and `Ash.Query.sort/2` are regular functions, not macros, but `Ash.Query.filter/2` IS a macro and DashboardLive correctly requires it.

2. **Factory module unused**: `test/support/factory.ex` defines an ExMachina factory but tests use `ConnCase.create_user/1` instead. The factory is dead code.

3. **ConferenceLive serialization pattern**: Both `serialize_tier/1` and DashboardLive's `serialize_conference/1` convert structs to string-keyed maps for LiveVue. This is fine for Vue interop, but consider documenting this pattern or extracting a shared helper if more serializers are needed.
