# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :juntos,
  ecto_repos: [Juntos.Repo],
  generators: [timestamp_type: :utc_datetime],
  ash_domains: [Juntos.Accounts, Juntos.Core]

config :juntos, Juntos.Repo, pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :juntos, :token_signing_secret, "dev-token-signing-secret-change-in-prod"

config :juntos, Oban,
  repo: Juntos.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, mailers: 5]

# Configure the endpoint
config :juntos, JuntosWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: JuntosWeb.ErrorHTML, json: JuntosWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Juntos.PubSub,
  live_view: [signing_salt: "WfCYt19L"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :juntos, Juntos.Mailer, adapter: Swoosh.Adapters.Local

# esbuild version still needed by the Elixir esbuild package (used for dep watchers)
# JS bundling itself is handled via assets/build.js (required for live_svelte plugins)
config :esbuild, :version, "0.25.4"

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  juntos: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
