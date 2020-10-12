defmodule LogflareTelemetry.BeamReporterTest do
  use ExUnit.Case, async: true
  use Mimic
  alias LogflareTelemetry.MetricsCache

  describe "Beam reporter" do
    test "handles vm events" do
      MetricsCache
      |> stub
      |> expect(:put, 3, fn _metric, tele_event ->
        send(self(), tele_event)
      end)

      measurements = %{
        atom: 1_261_873,
        atom_used: 1_247_612,
        binary: 978_512,
        code: 25_317_891,
        ets: 10_539_640,
        processes: 26_089_424,
        processes_used: 26_042_776,
        system: 61_332_432,
        total: 87_421_856
      }

      :telemetry.execute([:vm, :memory], measurements, %{})
      assert_receive %{measurements: ^measurements}

      measurements = %{cpu: 1, io: 0, total: 1}
      :telemetry.execute([:vm, :total_run_queue_lengths], measurements, %{})
      assert_receive %{measurements: ^measurements}

      measurements = %{
        atom_count: 41147,
        port_count: 36,
        process_count: 634
      }

      :telemetry.execute([:vm, :system_counts], measurements, %{})
      assert_receive %{measurements: ^measurements}
    end
  end
end
