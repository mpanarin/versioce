defmodule Versioce.TestHelper.FailingHook do
	use Versioce.PreHook

  def run(_) do
	  {:error, "Hook failed"}
  end
end


ExUnit.start()
