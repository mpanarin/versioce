defmodule Versioce.TestHelper.FailingHook do
  use Versioce.PreHook

  def run(_) do
    {:error, "Hook failed"}
  end
end

Mimic.copy(Versioce.Bumper.Files)
Mimic.copy(Versioce.Git)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
