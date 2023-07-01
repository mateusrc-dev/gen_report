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

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, 'Please, provider a list of string!'}
  end

  def build_from_many(filenames) do
    result =
      filenames
      |> Task.async_stream(fn filenames -> build(filenames) end)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)

    {:ok, result}
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

  defp sum_reports(
         %{
           "all_hours" => names1,
           "hours_per_month" => namesWithMonths1,
           "hours_per_year" => namesWithYears1
         },
         %{
           "all_hours" => names2,
           "hours_per_month" => namesWithMonths2,
           "hours_per_year" => namesWithYears2
         }
       ) do
    names = merge_maps1(names1, names2)
    namesWithMonths = merge_maps2(namesWithMonths1, namesWithMonths2)
    namesWithYears = merge_maps2(namesWithYears1, namesWithYears2)

    build_report(names, namesWithMonths, namesWithYears)
  end

  defp merge_maps1(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_maps2(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 ->
      Map.merge(value1, value2, fn _key, inside_value1, inside_value2 ->
        inside_value1 + inside_value2
      end)
    end)
  end

  defp report_acc do
    names = Enum.into(@name_worker, %{}, &{&1, 0})
    months = Enum.into(@months, %{}, &{&1, 0})
    namesWithMonths = Enum.into(@name_worker, %{}, &{&1, months})
    years = Enum.into(2016..2020, %{}, &{&1, 0})
    namesWithYears = Enum.into(@name_worker, %{}, &{&1, years})

    build_report(names, namesWithMonths, namesWithYears)
  end

  defp build_report(names, namesWithMonths, namesWithYears) do
    %{
      "all_hours" => names,
      "hours_per_month" => namesWithMonths,
      "hours_per_year" => namesWithYears
    }
  end
end
