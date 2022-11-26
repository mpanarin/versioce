defmodule Versioce.Bumper.CalverFormattingParser do
  @moduledoc """
  Module that parses and converts a CalVer format to and actual
  Version value
  """

  @available_parts ["YYYY", "MM", "0M", "DD", "0D"]

  @spec parse_format(String.t(), Date.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def parse_format(format, today) do
    parts =
      format
      |> String.split(".", trim: true)

    with 3 <- length(parts),
         true <-
           parts
           |> Enum.map(fn part -> Enum.member?(@available_parts, part) end)
           |> Enum.all?() do
      convert_parts(parts, today)
    else
      _ -> {:error, "Bad CalVer format: #{format}"}
    end
  end

  defp convert_parts([_part1, _part2, _part3] = parts, today) do
    new_version =
      parts
      |> Enum.map_join(".", fn part ->
        convert_part(part, today)
      end)

    {:ok, new_version}
  end

  defp convert_part("YYYY", date) do
    date.year |> to_string
  end

  defp convert_part("MM", date) do
    date.month |> to_string
  end

  defp convert_part("0M", date) do
    date.month |> to_string |> String.pad_leading(2, ["0"])
  end

  defp convert_part("DD", date) do
    date.day |> to_string
  end

  defp convert_part("0D", date) do
    date.day |> to_string |> String.pad_leading(2, ["0"])
  end
end
