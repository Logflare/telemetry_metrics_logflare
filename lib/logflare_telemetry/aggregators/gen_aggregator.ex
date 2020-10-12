defmodule LogflareTelemetry.Aggregators.GenAggregator do
  alias LogflareTelemetry, as: LT
  alias LT.MetricsCache
  alias LT.Transformer
  alias LT.BatchCache

  def dispatch(metric, value, config) do
    if measurement_exists?(value) do
      metric
      |> Transformer.event_to_payload(value, config)
      |> List.wrap()
      |> transform_to_logs_ingest_dispatch()
      |> Enum.map(&put(&1, config))
    end

    MetricsCache.reset(metric)
  end

  def put(%{"message" => m, "metadata" => meta} = ev, config) do
    BatchCache.put(ev, config)
  end

  def measurement_exists?(nil), do: false
  def measurement_exists?([]), do: false
  def measurement_exists?(_), do: true

  def transform_to_logs_ingest_dispatch(values) do
    for value <- values do
      message =
        value
        |> Map.to_list()
        |> hd
        |> elem(0)

      message =
        message
        |> String.replace("logflare.", "")

      value
    end
  end
end
