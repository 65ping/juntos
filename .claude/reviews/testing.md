## Testing Review

### Missing Test Coverage

1. **ConferenceLive: No test for `starts_at` date rendering**
   - The template conditionally renders `starts_at` with `Calendar.strftime/2`, but no test creates a conference with a `starts_at` value to verify the date format renders correctly.

2. **DashboardLive: No test for duplicate slug handling**
   - When two conferences have the same name, `build_slug/1` produces the same slug, and the Ash unique identity should produce an error. There is no test verifying the user gets a meaningful error message in this case.

3. **DashboardLive: No test for `delete_conference` with invalid/nonexistent ID**
   - The handler has a code path for `{:error, _}` but no test exercises it. Only the "not found" and "other user's conference" paths are tested.

4. **No tests for the SendMagicLink sender**
   - `lib/juntos/accounts/user/senders/send_magic_link.ex` has test coverage via `test/juntos/accounts/send_magic_link_test.exs` (good), but worth confirming both the `%{email: email}` struct path and the plain string path are tested.

5. **No integration test for conference with ticket tiers displayed via LiveVue**
   - The test at `conference_live_test.exs:41-52` checks that the HTML contains "ConferenceTickets" but cannot verify the Vue component actually renders tier data correctly, since that happens client-side.

### Test Quality Issues

1. **TictactoeLive: `:sys.get_state` usage is fragile**
   - File: `test/juntos_web/live/tictactoe_live_test.exs:121-128`
   - Using `:sys.get_state(view.pid)` to inspect LiveView internals is an anti-pattern. It reaches into process internals and can break on LiveView upgrades. The test should instead assert on rendered output or use `render_hook` return values. For LiveVue components this may be unavoidable if the rendering is done client-side, but it should be documented as a known tradeoff.

2. **DashboardLive test checks raw JSON strings**
   - File: `test/juntos_web/live/dashboard_live_test.exs:20,43`
   - Assertions like `render(view) =~ "&quot;conferences&quot;:[]"` are brittle. They depend on HTML-escaped JSON serialization format. If the Vue component changes how it receives props, these tests break for the wrong reason.

3. **Conference status badge test uses `Ash.Seed.seed!` directly**
   - File: `test/juntos_web/live/conference_live_test.exs:81-86`
   - This bypasses Ash actions/validations (intentionally for seeding), which is fine, but it means the test does not verify that these statuses are achievable through the normal action API.

### Pattern Recommendations

1. **Consider extracting test helpers for LiveVue JSON assertions** -- Since the project uses LiveVue and assertions often involve serialized JSON in HTML, a helper like `assert_vue_prop(html, "conferences", fn conferences -> ... end)` would make tests more readable and less brittle.

2. **Mox is declared as a dependency but unused** -- `mox` is in `mix.exs` but no Mox behaviors or expectations are defined anywhere. This is dead weight unless planned for future use (e.g., mocking the mailer in unit tests).

3. **ExMachina factory is declared but unused** -- `test/support/factory.ex` defines `Juntos.Factory` with `user_factory/0`, but all tests use `ConnCase.create_user/1` instead. Either remove the factory or migrate helpers to use it consistently.
