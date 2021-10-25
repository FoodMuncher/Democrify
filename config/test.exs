import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :democrify, DemocrifyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "RhW8cxZ5wqxw2dY/ejXmFXoX+qfXXmRBnbTkZyQNRZ7uKDD46pZNM2IL5fdxiYEq",
  server: false

# In test we don't send emails.
config :democrify, Democrify.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :critical

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
