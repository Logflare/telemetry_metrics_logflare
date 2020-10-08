defmodule LogflareTelemetry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Telemetry.Metrics
  alias LogflareTelemetry, as: LT
  alias LT.{Reporters, Aggregators}
  alias LT.RawMetrics
  alias LT.MetricsCache
  alias LT.Config
  alias LogflareTelemetry.BatchCache
  alias LogflareTelemetry.ApiClient
  @backend Logflare.TelemetryBackend

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
      {Aggregators.Ecto, config}
      # BEAM
      # {Reporters.BEAM, config},
      # {Aggregators.BEAM, config},
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
        ecto: %{
          metrics: metrics(:beam),
          tick_interval: 1_000
        }
      }
    )
  end

  def metrics(:ecto) do
    event_id = [:logflare, :repo, :query]
    measurement_names = ~w[decode_time query_time queue_time total_time]a

    measurement_names
    |> Enum.map(&[Metrics.summary(event_id ++ [&1])])
    |> Enum.concat([ExtMetrics.every(event_id)])
    |> List.flatten()
  end

  def metrics(:beam) do
    # last atom is required to subscribe to the teleemetry events but is irrelevant as all measurements are collected
    vm_memory = [:vm, :memory]
    vm_total_run_queue_lengths = [:vm, :total_run_queue_lengths]

    [
      ExtMetrics.last_values(vm_memory),
      ExtMetrics.last_values(vm_total_run_queue_lengths)
    ]
  end
end
