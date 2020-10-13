defmodule TelemetryMetricsLogflare.Reporters.Phoenix do
  @moduledoc """
  Reports Phoenix telemetry events
  """

  use GenServer
  require Logger
  @env Mix.env()
  alias TelemetryMetricsLogflare, as: LT
  alias LT.Reporters.Gen, as: Reporter
  alias LT.MetricsCache
  alias LT.LogflareMetrics
  require Logger

  @default_conn_keys [
    :method,
    :host,
    # :params,
    :path_info,
    :port,
    :remote_ip,
    :request_path,
    :scheme,
    :status
  ]

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(config) do
    Logger.info("Logflare Telemetry Phoenix Reporter is being initialized...")

    if @env != :test do
      Process.flag(:trap_exit, true)
    end

    attach_handlers(config.phoenix.metrics)

    {:ok, %{}}
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def attach_handlers(metrics) do
    Logger.debug("Logflare Telemetry Phoenix Reporter is attaching handlers")

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
      phx: prepare_metadata(metadata.conn),
      measurements: measurements
    }

    MetricsCache.push(metric, tele_event)
  end

  def handle_metric(metric, measurements, metadata) do
    Reporter.handle_metric(metric, measurements, metadata)
  end

  def prepare_metadata(metadata) do
    metadata
    |> Map.take(@default_conn_keys)
    |> Map.update(:remote_ip, nil, &(:inet.ntoa(&1) |> to_string))
    |> Enum.map(fn
      {k, v} when k in @default_conn_keys and is_number(v) ->
        {k, v}

      {k, v} when k in @default_conn_keys and is_atom(v) ->
        {k, to_string(v)}

      {k, v} when k in @default_conn_keys and is_list(v) ->
        {k, Enum.map(v, &to_string/1)}

      {k, v} when k in @default_conn_keys and is_map(v) ->
        {k, inspect(v)}

      kv ->
        kv
    end)
    |> Enum.filter(fn
      {_k, nil} -> false
      _ -> true
    end)
    |> Map.new()
  end

  def terminate(_, events) do
    Logger.warn("Logflare Telemetry Phoenix Reporter is detaching handlers!")
    Enum.each(events, &:telemetry.detach({__MODULE__, &1, self()}))
    :ok
  end
end
