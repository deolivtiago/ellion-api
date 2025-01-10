# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ellion,
  namespace: EllionCore,
  ecto_repos: [EllionCore.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configures the endpoint
config :ellion, EllionWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: EllionWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: EllionCore.PubSub,
  live_view: [signing_salt: "tNPk4VPt"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ellion, EllionCore.Mailer, adapter: Swoosh.Adapters.Local

config :ellion, EllionCore.JsonWebToken,
  jwt_secret_key:
    System.get_env(
      "JWT_SECRET_KEY",
      "H59i+xtsTruOIcRMvyDxtS3CcZE5Icf0q82RE1UNSQd0uUfETRrUNfK6zHaf0Ezw"
    )

# Configures the database timezone
config :elixir, :time_zone_database, Tz.TimeZoneDatabase
# Configures Goal's options
config :goal,
  password_regex: ~r/^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[.!?@#$%^&*_+\-])/,
  url_regex:
    ~r/(https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z]{2,}(\.[a-zA-Z]{2,})(\.[a-zA-Z]{2,})?\/[a-zA-Z0-9]{2,}|((https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z]{2,}(\.[a-zA-Z]{2,})(\.[a-zA-Z]{2,})?)|(https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z0-9]{2,}\.[a-zA-Z0-9]{2,}\.[a-zA-Z0-9]{2,}(\.[a-zA-Z0-9]{2,})?/

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
