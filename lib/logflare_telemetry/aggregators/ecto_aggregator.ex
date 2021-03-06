defmodule TelemetryMetricsLogflare.Aggregators.Ecto do
  @moduledoc """
  Aggregates Ecto telemetry metrics
  """
  use GenServer
  alias TelemetryMetricsLogflare.MetricsCache
  alias Telemetry.Metrics.{Summary}
  alias TelemetryMetricsLogflare, as: LT
  alias LT.Aggregators.GenAggregator
  @default_percentiles [25, 50, 75, 90, 95, 99]
  @default_summary_fields [:average, :median, :percentiles]
  alias LT.Config

  def start_link(config, opts \\ []) do
    GenServer.start_link(__MODULE__, config, opts)
  end

  @impl true
  def init(%Config{} = config) do
    Process.send_after(self(), :tick, config.ecto.tick_interval)
    {:ok, %{config: config}}
  end

  @impl true
  def handle_info(:tick, %{config: config} = state) do
    for metric <- config.ecto.metrics do
      value = MetricsCache.get(metric)

      {:ok, value} =
        case metric do
          %Summary{} ->
            case value do
              {:ok, nil} ->
                {:ok, nil}

              {:ok, []} ->
                {:ok, nil}

              {:ok, value} ->
                value =
                  value
                  |> Statistex.statistics(percentiles: @default_percentiles)
                  |> Map.take(@default_summary_fields)

                {:ok, value}
            end

          _ ->
            value
        end

      GenAggregator.dispatch(metric, value, config)
      MetricsCache.reset(metric)
    end

    Process.send_after(self(), :tick, config.ecto.tick_interval)
    {:noreply, state}
  end
end
