defmodule Versioce.Bumper do
  def current_version do
    case Mix.Project.get do
      nil -> {:error, "No project configured"}
      _ -> {:ok, Mix.Project.config[:version]}
    end
  end

  def bump(params) do
    current_version
  end
end
