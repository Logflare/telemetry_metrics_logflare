defmodule TelemetryMetricsLogflare.PhoenixReporterTest do
  use ExUnit.Case, async: true
  use Mimic
  alias TelemetryMetricsLogflare.MetricsCache
  @moduletag :this

  describe "Phoenix reporter" do
    test "handles endpoint stop event" do
      MetricsCache
      |> stub
      |> expect(
        :push,
        1,
        fn _metric, tele_event ->
          send(self(), tele_event)
        end
      )

      measurements = %{
        duration: 1000
      }

      :telemetry.execute(
        [:phoenix, :endpoint, :stop],
        measurements,
        %{conn: %{assigns: %{should_not_be_received: true}}}
      )

      assert_receive %{measurements: ^measurements, phx: metadata}
      refute get_in(metadata, [:conn, :assigns, :should_not_be_received])
    end
  end
end
