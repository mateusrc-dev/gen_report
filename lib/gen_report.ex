defmodule GenReport do
  alias GenReport.Parser

  @name_worker [
    "Daniele",
    "Mayk",
    "Giuliano",
    "Cleiton",
    "Jakeliny",
    "Joseph",
    "Diego",
    "Rafael",
    "Danilo",
    "Vinicius"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @options [
    "year",
    "month"
  ]

  def build(filename) do
    result = File.read("reports/#{filename}")

    case result do
      {:error, :enoent} ->
        {:error, "report is not provider!"}

      _ ->
        filename
        |> Parser.parser_file()
        |> Enum.reduce(report_acc(), fn line, report ->
          sum_values(line, report)
        end)
    end
  end

  def fetch_higher_hour(report) do
    {:ok, Enum.max_by(report["all_hours"], fn {_key, value} -> value end)}
  end

  def fetch_higher_hour_by_month_or_year(report, option, name)
      when option in @options and name in @name_worker do
    case option do
      "month" ->
        {:ok, Enum.max_by(report["hours_per_month"][name], fn {_key, value} -> value end)}

      "year" ->
        {:ok, Enum.max_by(report["hours_per_year"][name], fn {_key, value} -> value end)}
    end
  end

  def fetch_higher_hour_by_month_or_year(_report, _option, _name) do
    {:error, "Option or name invalid!"}
  end

  defp sum_values(
         [name, hours, _day, month, year],
         %{
           "all_hours" => names,
           "hours_per_month" => namesWithMonths,
           "hours_per_year" => namesWithYears
         } = report
       ) do
    all_hours = Map.put(names, name, names[name] + hours)

    namesWithMonths =
      Map.put(
        namesWithMonths,
        name,
        Map.put(namesWithMonths[name], month, namesWithMonths[name][month] + hours)
      )

    namesWithYears =
      Map.put(
        namesWithYears,
        name,
        Map.put(namesWithYears[name], year, namesWithYears[name][year] + hours)
      )

    report
    |> Map.put("all_hours", all_hours)
    |> Map.put("hours_per_month", namesWithMonths)
    |> Map.put("hours_per_year", namesWithYears)
  end

  defp report_acc do
    names = Enum.into(@name_worker, %{}, &{&1, 0})
    months = Enum.into(@months, %{}, &{&1, 0})
    namesWithMonths = Enum.into(@name_worker, %{}, &{&1, months})
    years = Enum.into(2016..2020, %{}, &{&1, 0})
    namesWithYears = Enum.into(@name_worker, %{}, &{&1, years})

    %{
      "all_hours" => names,
      "hours_per_month" => namesWithMonths,
      "hours_per_year" => namesWithYears
    }
  end
end
