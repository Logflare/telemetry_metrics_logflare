defmodule LogflareTelemetry.Reporters.BEAM do
  @moduledoc """
  Custom LogflareTelemetry reporter for handling BEAM telemetry events
  """
  use GenServer
  require Logger
  @env Mix.env()
  alias LogflareTelemetry.MetricsCache
  alias LogflareTelemetry, as: LT
  alias LT.LogflareMetrics

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @impl true
  def init(config) do
    if @env != :test do
      Process.flag(:trap_exit, true)
    end

    attach_handlers(config.beam.metrics)

    {:ok, %{}}
  end

  def attach_handlers(metrics) do
    metrics
    |> Enum.group_by(& &1.event_name)
    |> Enum.each(fn {event, metrics} ->
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &handle_event/4, metrics)
    end)
  end

  def handle_event(_event_name, measurements, metadata, metrics) do
    Enum.map(metrics, &handle_metric(&1, measurements, metadata))
  end

  def handle_metric(%LogflareMetrics.LastValues{} = metric, measurements, _metadata) do
    tele_event = %{
      measurements: extract_measurement(metric, measurements)
    }

    MetricsCache.put(metric, tele_event)
  end

  @impl true
  def terminate(_, events) do
    Logger.warn("Logflare Telemetry BEAM Reporter is detaching handlers!")
    Enum.each(events, &:telemetry.detach({__MODULE__, &1, self()}))
    :ok
  end

  defp extract_measurement(metric, measurements) do
    case metric.measurement do
      fun when is_function(fun, 1) -> fun.(measurements)
      key -> measurements[key]
    end
  end
end
