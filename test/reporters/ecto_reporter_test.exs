defmodule TelemetryMetricsLogflare.EctoReporterTest do
  use ExUnit.Case, async: true
  use Mimic
  alias TelemetryMetricsLogflare.MetricsCache
  doctest TelemetryMetricsLogflare
  @telem_used_by_app :test_app

  describe "Ecto reporter" do
    test "handles repo query event" do
      MetricsCache
      |> expect(:push, fn _metric, tele_event ->
        send(self(), tele_event)
      end)

      :telemetry.execute(
        [@telem_used_by_app, :repo, :query],
        %{
          decode_time: 1,
          compile_time: 2,
          queue_time: 3,
          total_time: 6
        },
        %{
          options: [],
          params: [1],
          query: "SELECT * FROM table",
          repo: Logflare.Repo,
          result:
            {:ok,
             %Postgrex.Result{
               columns: ["id", "data", "inserted_at", "updated_at"],
               command: :select,
               connection_id: 1,
               messages: [],
               num_rows: 1,
               rows: [
                 [1, "data", ~N[2020-04-27 17:34:00.000000], ~N[2020-10-06 18:14:56.000000]]
               ]
             }},
          source: "table",
          type: :ecto_sql_query
        }
      )

      assert_receive %{
        ecto: %{
          params: "[1]",
          query: "SELECT * FROM table",
          repo: "Logflare.Repo",
          source: "table"
        },
        measurements: %{compile_time: 2, decode_time: 1, queue_time: 3, total_time: 6}
      }
    end
  end
end
