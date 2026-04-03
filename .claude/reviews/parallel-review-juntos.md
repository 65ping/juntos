# Parallel Code Review: Juntos (Full Codebase)

## Summary

- **Status**: Approved with Suggestions
- **Blocking Issues**: 1
- **Warnings**: 7
- **Suggestions**: 6

## Quick Verdict

The Juntos codebase is well-structured and clean. All automated checks pass (compilation, formatting, Credo strict, 80/80 tests). The Ash Framework is used idiomatically, LiveVue integration works correctly, and the DashboardLive authorization pattern properly scopes mutations to the owning user. The single blocking issue is a database query during disconnected mount in ConferenceLive, which violates an Iron Law and doubles query load. Several warnings around missing `@impl true` annotations, bang-function error handling, and the absence of Ash resource-level policies should be addressed before the codebase grows further.

---

## Correctness & Style (elixir-reviewer)

### Critical Issues (Must Fix)

1. **ConferenceLive: Database query in disconnected mount** (Iron Law violation)
   - `lib/juntos_web/live/conference_live.ex:7-21`
   - `mount/3` calls `load_conference(slug)` unconditionally, hitting the database before the WebSocket connects. DashboardLive correctly checks `connected?(socket)` before querying. ConferenceLive should do the same.

### Warnings (Should Fix)

2. **Missing `@impl true` annotations in ConferenceLive and DashboardLive**
   - Both modules omit `@impl true` on `mount/3`, `handle_event/3`, and `render/1`. TictactoeLive correctly uses `@impl true`. Without it, the compiler cannot catch callback name typos.

3. **`Ash.destroy!` in DashboardLive can crash the LiveView**
   - `lib/juntos_web/live/dashboard_live.ex:63` -- Use `Ash.destroy/1` with error handling instead of the bang variant.

4. **`Ash.read!` in `load_conferences/1` can crash**
   - `lib/juntos_web/live/dashboard_live.ex:88` -- A DB timeout crashes the process. Use `Ash.read/1`.

5. **Missing catch-all clauses for `status_classes/1` and `status_label/1`**
   - `lib/juntos_web/live/conference_live.ex:103-122` -- Adding a new status atom causes a `FunctionClauseError`.

### Style Suggestions

6. **`String.to_integer("#{index}")` is redundant** -- `tictactoe_live.ex:22` -- Drop the interpolation.
7. **Dead code: `test/support/factory.ex`** -- ExMachina factory is defined but never used.

---

## Security (security-analyzer)

### Critical Vulnerabilities

None found.

### Security Warnings

1. **No Ash policies defined on any resource** -- Conference and TicketTier rely entirely on LiveView-level scoping for authorization. This is fragile as the number of code paths grows. Adding `Ash.Policy.Authorizer` provides defense-in-depth.

2. **Session cookie lacks `encryption_salt`** -- `lib/juntos_web/endpoint.ex:7-12` -- Session data is signed but not encrypted, making JWT tokens readable if the cookie is intercepted (TLS protects in transit, but at-rest on the client the token is visible).

3. **TicketTier has no authorization at all** -- `:create` and `:destroy` actions are callable by any code path that can reach the resource.

### Authorization Gaps

4. **ConferenceLive `get_ticket` handler** -- Currently a no-op, but when implemented must validate the tier belongs to the loaded conference and authorize the user.

---

## Testing (testing-reviewer)

### Missing Test Coverage

1. No test for `starts_at` date rendering in ConferenceLive.
2. No test for duplicate slug error handling in DashboardLive.
3. No test for `delete_conference` with a completely invalid/nonexistent ID.

### Test Quality Issues

4. **`:sys.get_state` in TictactoeLive tests** (`test/juntos_web/live/tictactoe_live_test.exs:121-128`) -- Reaches into LiveView process internals. Fragile across LiveView upgrades.
5. **HTML-escaped JSON string assertions** (`dashboard_live_test.exs:20,43`) -- Assertions like `=~ "&quot;conferences&quot;:[]"` are brittle.

### Pattern Recommendations

6. **Unused dependencies**: `mox` and `ex_machina` are declared but not used in any test.

---

## Verification (verification-runner)

| Check | Result |
|-------|--------|
| Compilation | PASS (0 warnings) |
| Formatting | PASS |
| Credo (strict) | PASS (0 issues) |
| Tests | PASS (80 passed, 0 failed) |
| Sobelow | SKIPPED (not installed) |

---

## Cross-Track Observations

1. **Authorization layering gap** -- The security track and correctness track both identify that authorization exists only at the LiveView layer (DashboardLive scoping) but not at the Ash resource layer. This is a consistent concern across both tracks.

2. **Bang functions and crash resilience** -- The correctness track flags `Ash.destroy!` and `Ash.read!`, while the testing track notes that no tests exercise the error paths for these operations. These are complementary findings: the code can crash, and the tests don't cover the crash scenarios.

3. **Dead dependencies** -- Both the correctness and testing tracks flag unused test dependencies (ExMachina factory, Mox).

## Cross-Track Conflicts

None found. All tracks are in agreement on findings and recommendations.

---

## Action Items (Prioritized)

### Must Fix (Blocking)

1. [ ] Add `connected?(socket)` check in `ConferenceLive.mount/3` before calling `load_conference/1` - **correctness**

### Should Fix

2. [ ] Add `@impl true` to all LiveView callbacks in ConferenceLive and DashboardLive - **correctness**
3. [ ] Replace `Ash.destroy!` with `Ash.destroy` + error handling in DashboardLive - **correctness**
4. [ ] Replace `Ash.read!` with `Ash.read` + error handling in `load_conferences/1` - **correctness**
5. [ ] Add catch-all clauses to `status_classes/1` and `status_label/1` - **correctness**
6. [ ] Add `encryption_salt` to session cookie options in Endpoint - **security**
7. [ ] Consider adding Ash policies to Conference and TicketTier resources - **security**
8. [ ] Add Sobelow to deps for static security analysis - **verification**

### Consider

9. [ ] Remove unused `test/support/factory.ex` and `:ex_machina` dep - **testing/correctness**
10. [ ] Remove unused `:mox` dependency or plan its usage - **testing**
11. [ ] Add tests for duplicate slug handling and `starts_at` rendering - **testing**
12. [ ] Replace `:sys.get_state` with output-based assertions where possible - **testing**
13. [ ] Extract LiveVue JSON assertion helpers for test readability - **testing**
14. [ ] Drop redundant string interpolation in `String.to_integer("#{index}")` - **correctness**
