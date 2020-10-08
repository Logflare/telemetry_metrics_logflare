defmodule LogflareTelemetry.Poller do
  @moduledoc false
  @poller_name :logflare_telemetry_poller
  @process_info_worker :logflare_beam_process_info_worker
  @sampling_period 1_000

  def start_link(args \\ %{}, _opts \\ []) do
    process_info = args[:process_info]

    Telemetry.Poller.start_link(
      vm_measurements: [:memory, :total_run_queue_lengths, :system_counts],
      period: @sampling_period,
      name: @poller_name
    )
  end
end
