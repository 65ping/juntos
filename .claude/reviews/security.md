## Security Review

### Critical Vulnerabilities

None found. The project uses Ash Framework, which provides parameterized queries by default, and AshAuthentication for session management. No `raw/1` usage with user content was detected.

### Security Warnings

1. **ConferenceLive: No authorization on `get_ticket` event**
   - File: `lib/juntos_web/live/conference_live.ex:24-26`
   - While currently a no-op (returns "coming soon" flash), the `handle_event("get_ticket", ...)` accepts a `tier_id` from the client without any validation. When this is implemented, the handler MUST validate the tier exists and belongs to the loaded conference. Establishing the authorization pattern now prevents future oversight.

2. **Conference `:destroy` action is globally accessible**
   - File: `lib/juntos/core/conference.ex:46` (defaults include `:destroy`)
   - The `defaults([:read, :destroy])` makes the destroy action callable by anyone with a Conference struct. DashboardLive does scope-check via `find_owned_conference`, but any code path that obtains a Conference struct can call `Ash.destroy!` on it. Consider adding Ash policies to enforce authorization at the resource level.

3. **TicketTier `:destroy` and `:create` actions have no authorization**
   - File: `lib/juntos/core/ticket_tier.ex:30-39`
   - Any code path can create or destroy ticket tiers for any conference. As the app grows, this becomes a vector for abuse.

4. **Token signing secret in compile-time config**
   - File: `config/config.exs:17`
   - `config :juntos, :token_signing_secret, "dev-token-signing-secret-change-in-prod"` is overridden by `runtime.exs` in prod, which is correct. However, if someone accidentally deploys with `MIX_ENV=dev`, this hardcoded secret would be used. The runtime.exs prod block raises if the env var is missing, so this is low risk but worth noting.

5. **Session cookie lacks encryption_salt**
   - File: `lib/juntos_web/endpoint.ex:7-12`
   - The session options include `signing_salt` but no `encryption_salt`. This means session data is signed (tamper-proof) but readable by anyone who intercepts the cookie. For a magic-link auth flow where the session contains a JWT token, this means the token is visible in the cookie. Consider adding `:encryption_salt` to encrypt the cookie contents.

### Authorization Gaps

1. **ConferenceLive public access is by design** -- the `/:slug` route is in the `:public` live session, so no auth is required. This is appropriate for a public conference page.

2. **DashboardLive authorization is properly scoped** -- the `delete_conference` handler correctly uses `find_owned_conference` which scopes queries to the current user's `organizer_id`. The `create_conference` handler assigns the current user as organizer. This is good.

3. **No Ash policies defined** -- The project relies on application-level authorization (LiveView scoping) rather than Ash policies. This works for a small codebase but becomes fragile as the number of code paths to resources grows. Consider adding `Ash.Policy.Authorizer` policies to Conference and TicketTier.
