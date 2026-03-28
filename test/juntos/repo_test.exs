defmodule Juntos.RepoTest do
  use ExUnit.Case, async: true

  describe "min_pg_version/0" do
    test "returns a Version struct for PostgreSQL 18" do
      assert %Version{major: 18, minor: 0, patch: 0} = Juntos.Repo.min_pg_version()
    end
  end

  describe "installed_extensions/0" do
    test "includes the ash-functions extension" do
      assert "ash-functions" in Juntos.Repo.installed_extensions()
    end

    test "includes uuid-ossp extension" do
      assert "uuid-ossp" in Juntos.Repo.installed_extensions()
    end

    test "includes citext extension" do
      assert "citext" in Juntos.Repo.installed_extensions()
    end
  end
end
