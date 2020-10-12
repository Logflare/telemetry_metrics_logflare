defmodule LogflareTelemetry.Reporters.Ecto do
  @moduledoc """
  Custom LogflareTelemetry reporter for handling Ecto repos telemetry events
  """
  use GenServer
  require Logger
  @env Application.get_env(:logflare, :env)
  alias LogflareTelemetry, as: LT
  alias LT.Reporters.Gen, as: Reporter
  alias LT.Reporters.Ecto.Transformer, as: EctoTransformer
  alias LogflareTelemetry.Transformer
  alias LT.MetricsCache
  alias LT.LogflareMetrics

  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(config) do
    Logger.info("Logflare Telemetry Ecto Reporter is being initialized...")

    if @env != :test do
      Process.flag(:trap_exit, true)
    end

    attach_handlers(config.ecto.metrics)

    {:ok, %{}}
  end

  def attach_handlers(metrics) do
    Logger.warn("Logflare Telemetry Ecto Reporter is attaching handlers")

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

  def handle_metric(%LogflareMetrics.Every{} = metric, measurements, metadata) do
    tele_event = %{
      measurements: measurements,
      ecto: EctoTransformer.prepare_metadata(metadata)
    }

    MetricsCache.push(metric, tele_event)
  end

  def handle_metric(metric, measurements, metadata) do
    Reporter.handle_metric(metric, measurements, metadata)
  end

  def terminate(_, events) do
    Enum.each(events, &:telemetry.detach({__MODULE__, &1, self()}))
    :ok
  end
end
