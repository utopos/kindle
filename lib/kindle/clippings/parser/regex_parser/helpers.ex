defmodule Kindle.Clippings.Parser.RegexParser.Helpers do
  @moduledoc false
  alias Kindle.Clippings.Clipping

  @regex_metadata ~r/^- Your (?<type>\w+) on (?<where>[^|]+) \|( Location (?<location>.*) \|){0,1} Added on \w+, (?<month>\w+) (?<day>\d+), (?<year>\d+) (?<timestr>[\d:]+) (?<period>AM|PM)$/

  @doc """
  Parses a single Kindle Clipping entry.

  ## Parameters

  * `entrystr`: string representing the whole entry  without "==========\r\n" ending sequence.

  ## Returns

  {:ok, %Kindle.Clippings.Clipping{...}
  OR
  {:error, entrystr}

  """
  @spec parse_entry(String.t()) :: {:ok, %Clipping{}} | {:error, String.t()}
  def parse_entry(entrystr) when is_binary(entrystr) do
    try do
      result =
        entrystr
        |> String.split("\r\n", trim: true)
        |> process_entry()

      {:ok, result}
    rescue
      _ -> {:error, entrystr}
    end
  end

  @spec process_entry([String.t()]) :: %Clipping{}
  defp process_entry([titlestr, metastr]), do: process_entry([titlestr, metastr, ""])

  defp process_entry([titlestr, metastr, content]) do
    {:ok, partial_result_1} = parse_metadata(metastr)
    title = remove_bom_from_start(titlestr)
    partial_result_2 = %{title: title, content: content}
    results = Map.merge(partial_result_1, partial_result_2)

    Clipping
    |> struct(results)
  end

  @doc """
  Parses Kindle Clipping seond line (metadata) into a map.

  ## Parameters
  - `metastr`: string containing whole line with metadata without newlines.

  ## Returns

  ```elixir
  {:ok,
      %{
        location: "2462-2465",
        type: "Highlight",
        where: "page 161",
        date: ~D[2014-09-25],
        time: ~T[16:11:25]
      }
    }```
  OR

  `{:error, metastr}`
  """
  @spec parse_metadata(String.t()) :: {:ok, map()} | {:error, String.t()}
  def parse_metadata(metastr) do
    try do
      %{
        "day" => day,
        "month" => month_str,
        "period" => period,
        "timestr" => timestr,
        "year" => year,
        "type" => type,
        "where" => where,
        "location" => location
      } = Regex.named_captures(@regex_metadata, metastr)

      {:ok, time} = parse_kindle_time(timestr, period)

      date = %Date{
        day: String.to_integer(day),
        month: month_to_number(month_str),
        year: String.to_integer(year)
      }

      location = if location === "", do: nil, else: location

      {:ok,
       %{
         location: location,
         type: type,
         where: where,
         date: date,
         time: time
       }}
    rescue
      _ -> {:error, metastr}
    end
  end

  @spec remove_bom_from_start(String.t()) :: String.t()
  defp remove_bom_from_start(<<"\uFEFF"::utf8, rest::binary>>), do: rest
  defp remove_bom_from_start(<<rest::binary>>), do: rest

  @doc """
  Converts Kindle format date to Time

  ## Parameters

  - `timestr`: string desciribing time as given by kindle (not ISO compillant)
  - `period`: "AM" or "PM"

  ## Example

  iex> Kindle.Clippings.Parser.RegexParser.Helpers.parse_kindle_time("1:30:45", "PM")
  {:ok, ~T[13:30:45]}

  iex> Kindle.Clippings.Parser.RegexParser.Helpers.parse_kindle_time("1:30:45", "AM")
  {:ok, ~T[01:30:45]}

  iex> Kindle.Clippings.Parser.RegexParser.Helpers.parse_kindle_time("1:30:XX", "ZM")
  {:error, {"1:30:XX", "ZM"}}

  """
  @spec parse_kindle_time(String.t(), String.t()) ::
          {:ok, Time.t()} | {:error, {timestr :: String.t(), period :: String.t()}}

  def parse_kindle_time(timestr, period) do
    try do
      [hour, minute, second] =
        timestr
        |> String.split(":", trim: true)
        |> Enum.map(&String.to_integer/1)

      hour =
        case period do
          "PM" -> hour + 12
          "AM" -> hour
        end

      {:ok, %Time{hour: hour, minute: minute, second: second}}
    rescue
      _ -> {:error, {timestr, period}}
    end
  end

  @doc """
  Converts month name in English to a number (1..12)

  ## Example

    iex> Kindle.Clippings.Parser.RegexParser.Helpers.month_to_number("January")
    1

    iex> Kindle.Clippings.Parser.RegexParser.Helpers.month_to_number("Blabla")
    nil

  """
  @spec month_to_number(month :: String.t()) :: 1..12
  def month_to_number("January"), do: 1
  def month_to_number("February"), do: 2
  def month_to_number("March"), do: 3
  def month_to_number("April"), do: 4
  def month_to_number("May"), do: 5
  def month_to_number("June"), do: 6
  def month_to_number("July"), do: 7
  def month_to_number("August"), do: 8
  def month_to_number("September"), do: 9
  def month_to_number("October"), do: 10
  def month_to_number("November"), do: 11
  def month_to_number("December"), do: 12
  def month_to_number(_), do: nil
end
