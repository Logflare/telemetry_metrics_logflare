defmodule LogflareTelemetry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias LogflareTelemetry, as: LT
  alias LT.{Reporters, Aggregators, Pollers}
  alias LT.LogflareMetrics
  alias LT.MetricsCache
  alias LT.Config
  alias LogflareTelemetry.BatchCache
  alias LogflareTelemetry.ApiClient

  @impl true
  def start(_type, _args) do
    config =
      Application.get_all_env(:logflare_telemetry)
      |> Map.new()

    config = Map.put(config, :api_client, ApiClient.new(config))
    config = merge_configs(config)

    config = struct!(Config, config)

    children = [
      MetricsCache,
      BatchCache,
      # Ecto
      {Reporters.Ecto, config},
      {Aggregators.Ecto, config},
      # BEAM
      {Reporters.BEAM, config},
      {Aggregators.BEAM, config},
      {Pollers.BEAM, config},
      # Phoenix
      {Reporters.Phoenix, config},
      {Aggregators.Phoenix, config}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LogflareTelemetry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def merge_configs(config) do
    Map.merge(
      config,
      %{
        beam: %{
          metrics: metrics(:beam),
          tick_interval: 1_000
        },
        broadway: %{
          metrics: [],
          tick_interval: 1_000
        },
        phoenix: %{
          metrics: metrics(:phoenix),
          tick_interval: 1_000
        },
        ecto: Map.new(config.ecto) |> Map.merge(%{metrics: metrics(:ecto), tick_interval: 1_000})
      }
    )
  end

  def metrics(:ecto) do
    event_ids = [
      [:logflare, :repo, :init],
      [:logflare, :repo, :query]
    ]

    _measurement_names = ~w[decode_time query_time queue_time total_time]a

    for id <- event_ids do
      LogflareMetrics.every(id)
    end
  end

  def metrics(:beam) do
    vm_memory = [:vm, :memory]
    vm_total_run_queue_lengths = [:vm, :total_run_queue_lengths]
    vm_system_counts = [:vm, :system_counts]

    # last atom is required to subscribe to the telemetry events but is irrelevant as all measurements are collected
    [
      LogflareMetrics.last_values(vm_memory),
      LogflareMetrics.last_values(vm_total_run_queue_lengths),
      LogflareMetrics.last_values(vm_system_counts)
    ]
  end

  def metrics(:phoenix) do
    [
      LogflareMetrics.every([:phoenix, :endpoint, :stop])
    ]
  end

  def metrics(:phoenix, :all) do
    # Phoenix Metrics
    [
      LogflareMetrics.every([:phoenix, :endpoint, :stop, :duration]),
      LogflareMetrics.every([:phoenix, :router_dispatch, :stop, :duration]),
      LogflareMetrics.every([:phoenix, :router_dispatch, :exception]),
      LogflareMetrics.every([:phoenix, :error_rendered]),
      LogflareMetrics.every([:phoenix, :channel_joined]),
      LogflareMetrics.every([:phoenix, :channel_handled_in])
    ]
  end
end
