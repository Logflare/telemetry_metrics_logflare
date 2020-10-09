defmodule LogflareTelemetry.PhoenixReporterTest do
  use ExUnit.Case, async: true
  use Mimic
  alias LogflareTelemetry.MetricsCache
  @moduletag :this

  describe "Phoenix reporter" do
    test "handles endpoint stop event" do
      MetricsCache
      |> stub
      |> expect(
        :push,
        1,
        fn metric, tele_event ->
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

      assert_receive %{measurements: ^measurements, metadata: metadata}
      refute get_in(metadata, [:conn, :assigns, :should_not_be_received])
    end
  end
end
