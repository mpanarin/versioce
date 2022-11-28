defmodule VersioceTest.Bumper.CalverFormattingParser do
  use ExUnit.Case, async: true
  alias Versioce.Bumper.CalverFormattingParser

  describe "parse_format/2" do
    test "returns a proper version with a proper format" do
      assert {:ok, "2022.1.1"} = CalverFormattingParser.parse_format("YYYY.MM.DD", ~D[2022-01-01])

      assert {:ok, "2022.01.01"} =
               CalverFormattingParser.parse_format("YYYY.0M.0D", ~D[2022-01-01])

      assert {:ok, "03.1994.10"} =
               CalverFormattingParser.parse_format("0D.YYYY.MM", ~D[1994-10-03])
    end

    test "returns an error with a bad format" do
      assert {:error, "Bad CalVer format: YYY.MM.DD"} =
               CalverFormattingParser.parse_format("YYY.MM.DD", ~D[2022-01-01])
    end
  end
end
