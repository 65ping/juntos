defmodule Juntos.Repo do
  use AshSqlite.Repo, otp_app: :juntos

  def installed_extensions do
    if Application.get_env(:juntos, __MODULE__)[:adapter] == Ecto.Adapters.SQLite3 do
      []
    else
      ["uuid-ossp", "citext"]
    end
  end
end
