defmodule TelemetryMetricsLogflare.Pollers.BEAM do
  @moduledoc false
  @poller_name :telemetry_metrics_logflare_poller_beam
  @sampling_period 1_000

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def start_link(_args \\ %{}, _opts \\ []) do
    :telemetry_poller.start_link(
      period: @sampling_period,
      name: @poller_name
    )
  end
end
