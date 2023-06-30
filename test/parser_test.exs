defmodule GenReport.ParserTest do
  use ExUnit.Case
  alias GenReport.Parser

  describe("parser_file/1") do
    test "parse the file" do
      file_name = "gen_reports_test.csv"

      response =
        file_name
        |> Parser.parser_file()
        |> Enum.map(fn result -> result end)

      expected_response = [
        ["Daniele", 7, 29, "abril", 2018],
        ["Mayk", 4, 9, "dezembro", 2019],
        ["Daniele", 5, 27, "dezembro", 2016],
        ["Mayk", 1, 2, "dezembro", 2017],
        ["Giuliano", 3, 13, "fevereiro", 2017],
        ["Cleiton", 1, 22, "junho", 2020],
        ["Giuliano", 6, 18, "fevereiro", 2019],
        ["Jakeliny", 8, 18, "julho", 2017],
        ["Joseph", 3, 17, "março", 2017],
        ["Jakeliny", 6, 23, "março", 2019]
      ]

      assert response == expected_response
    end
  end
end
