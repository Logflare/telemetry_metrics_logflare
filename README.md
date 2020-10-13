# TelemetryMetricsLogflare

`TelemetryMetricsLogflare` makes it easy to ship individual `Telemetry` events to Logflare to easily search and dashboard your application events.

TelemetryMetricsLogflare does not aggregate metrics in your app. It sends individual events and metadata to Logflare so you can dynamically query your metrics without having to create 10s, 1000s or millions of separate metrics. This lets you drill down to the actual events which make up an aggregation and lets you do dynamic aggregations on historical data.

## Supported Metrics

### TelemetryPoller
- [x] `[vm, memory]`
- [x] `[vm, total_run_queue_lengths]`
- [x] `[vm, system_counts]`

### Broadway
https://hexdocs.pm/broadway/Broadway.html#module-telemetry

- [ ] `[:broadway, :processor, :start]`
- [ ] `[:broadway, :processor, :stop]`
- [ ] `[:broadway, :processor, :message, :start]`
- [ ] `[:broadway, :processor, :message, :stop]`
- [ ] `[:broadway, :processor, :message, :exception]`
- [ ] `[:broadway, :consumer, :start]`
- [ ] `[:broadway, :consumer, :stop]`
- [ ] `[:broadway, :batcher, :start]`
- [ ] `[:broadway, :batcher, :stop]`

### Phoenix
https://hexdocs.pm/phoenix/Phoenix.Logger.html#module-instrumentation


- [ ] `[:phoenix, :endpoint, :start]`
- [x] `[:phoenix, :endpoint, :stop]`
- [ ] `[:phoenix, :router_dispatch, :start]`
- [ ] `[:phoenix, :router_dispatch, :exception]`
- [ ] `[:phoenix, :router_dispatch, :stop]`
- [ ] `[:phoenix, :error_rendered]`
- [ ] `[:phoenix, :socket_connected]`
- [ ] `[:phoenix, :channel_joined]`
- [ ] `[:phoenix, :channel_handled_in]`

### Ecto
https://hexdocs.pm/ecto/Ecto.Repo.html#module-telemetry-events

- [ ] `[:ecto, :repo, :init]`
- [x] `[:my_app, :repo, :query]`

### Oban
https://hexdocs.pm/oban/Oban.Telemetry.html

- [ ] `[:oban, :job, :start]`
- [ ] `[:oban, :job, :stop]`
- [ ] `[:oban, :job, :exception]`

 ### Plug
 https://hexdocs.pm/plug/Plug.Telemetry.html

 - [ ] `[:my, :plug, :start]`
 - [ ] `[:my, :plug, :stop]`

 ### Tesla
 https://hexdocs.pm/tesla/Tesla.Middleware.Telemetry.html

 - [ ] `[:tesla, :request, :start]`
 - [ ] `[:tesla, :request, :stop]`
 - [ ] `[:tesla, :request, :exception]`

## Configuration 

In your config.exs: 

```elixir
config :telemetry_metrics_logflare,
  ecto: [applications: :your_app],
  url: "https://api.logflare.app",
  api_key: "YOUR_INGEST_API_KEY",
  source_id: "YOUR_SOURCE_ID",
  max_batch_size: 5,
  tick_interval: 1_000
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `telemetry_metrics_logflare` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:telemetry_metrics_logflare, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/telemetry_metrics_logflare](https://hexdocs.pm/telemetry_metrics_logflare).

