import Config

# Disable protocol consolidation to fix OTP 28 cover tool compatibility
# The cover tool can't handle consolidated protocol beam files
config :elixir, consolidate_protocols: false

config :juntos, Juntos.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "juntos_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :juntos, JuntosWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "3VtRhkMx7bIoQ2DcQ6DYDPqMA5cfP1ZcispCfJVfhvfsg/j9uSG861IftGgkWHmj",
  server: true

config :phoenix_test,
  otp_app: :juntos,
  endpoint: JuntosWeb.Endpoint,
  base_url: "http://localhost:4002"

# In test we don't send emails
config :juntos, Juntos.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

config :juntos, :sql_sandbox, true

config :juntos, Oban, testing: :inline

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
