import Config

config :telemetry_metrics_logflare,
  ecto: [
    applications: :logflare
  ],
  url: "localhost:4000",
  api_key: "PtzT2OSVy6LQ",
  source_id: "756a5c4c-b607-44c5-ac00-e80dfe05b7bc",
  max_batch_size: 5,
  tick_interval: 1_000
