ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Juntos.Repo, :manual)
{:ok, _} = PhoenixTest.Playwright.Supervisor.start_link()
