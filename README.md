# TelemetryMetricsLogflare

`TelemetryMetricsLogflare` makes it easy to ship individual `Telemetry` metrics events to [Logflare](https://logflare.app). Easily search, dashboard and drill down into your application metrics with Logflare.

TelemetryMetricsLogflare does not aggregate metrics in your app. It sends individual events and metadata to Logflare so you can dynamically query your metrics without having to create 10s, 1000s or millions of separate metrics. This lets you drill down to the actual events which make up an aggregation and lets you do dynamic aggregation on historical data.

## Example

### Ecto
Give me the 99th percentile total query time of queries from the `properties` table.

Logflare query: `m.ecto.source:"properties" c:p99(m.refinder.repo.query.every.total_time) c:group_by(t::minute)`

![Ecto TelemetryMetricsLogflare example](https://p195.p4.n0.cdn.getcloudapp.com/items/YEuyQpQY/Screen%20Shot%202020-10-13%20at%201.27.03%20PM.png?v=0a731c4ef30658613f8743e54f2351ea)

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
- [ ] `[:phoenix, :live_view, :mount, :start]`
- [ ] `[:phoenix, :live_view, :mount, :stop]`
- [ ] `[:phoenix, :live_view, :mount, :exception]`
- [ ] `[:phoenix, :live_view, :handle_params, :start]`
- [ ] `[:phoenix, :live_view, :handle_params, :stop]`
- [ ] `[:phoenix, :live_view, :handle_params, :exception]`
- [ ] `[:phoenix, :live_view, :handle_event, :start]`
- [ ] `[:phoenix, :live_view, :handle_event, :stop]`
- [ ] `[:phoenix, :live_view, :handle_event, :exception]`
- [ ] `[:phoenix, :live_component, :handle_event, :start]`
- [ ] `[:phoenix, :live_component, :handle_event, :stop]`
- [ ] `[:phoenix, :live_component, :handle_event, :exception]`

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

