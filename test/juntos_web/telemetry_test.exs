defmodule JuntosWeb.TelemetryTest do
  use ExUnit.Case, async: true

  describe "metrics/0" do
    test "returns a list of telemetry metrics" do
      assert is_list(JuntosWeb.Telemetry.metrics())
    end

    test "includes Phoenix endpoint metrics" do
      names = Enum.map(JuntosWeb.Telemetry.metrics(), & &1.name)
      assert [:phoenix, :endpoint, :stop, :duration] in names
    end

    test "includes Repo query metrics" do
      names = Enum.map(JuntosWeb.Telemetry.metrics(), & &1.name)
      assert [:juntos, :repo, :query, :total_time] in names
    end

    test "includes VM memory metrics" do
      names = Enum.map(JuntosWeb.Telemetry.metrics(), & &1.name)
      assert [:vm, :memory, :total] in names
    end
  end
end
