defmodule TelemetryMetricsLogflare.Aggregators.BEAM do
  @moduledoc """
  Aggregates BEAM telemetry metrics
  """
  use GenServer
  alias TelemetryMetricsLogflare.MetricsCache
  alias TelemetryMetricsLogflare, as: LT
  alias LT.Aggregators.GenAggregator
  alias LT.Config

  def start_link(%Config{} = config, opts \\ []) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  @impl true
  def init(%Config{} = config) do
    Process.send_after(self(), :tick, config.beam.tick_interval)
    {:ok, %{config: config}}
  end

  @impl true
  def handle_info(:tick, %{config: %Config{} = config} = state) do
    for metric <- config.beam.metrics do
      {:ok, value} =
        case metric do
          _ ->
            MetricsCache.get(metric)
        end

      GenAggregator.dispatch(metric, value, config)
      MetricsCache.reset(metric)
    end

    Process.send_after(self(), :tick, config.beam.tick_interval)
    {:noreply, state}
  end
end
