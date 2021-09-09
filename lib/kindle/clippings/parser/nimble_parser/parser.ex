defmodule Kindle.Clippings.Parser.NimbleParser.Parser do
  @moduledoc false
  import NimbleParsec

  alias Kindle.Clippings.Parser.RegexParser.Helpers
  alias Kindle.Clippings.Clipping
  alias Kindle.Clippings.Parser.NimbleParser.Parser, as: NParser


  eol = string("\r\n")
  double_eol = concat(eol, eol)

  line = utf8_string([not: ?\r], min: 0)

  # month
  date =
    utf8_string([not: ?\s], min: 1)
    |> ignore(string(" "))
    # day
    |> choice([integer(2), integer(1)])
    |> ignore(string(", "))
    # year
    |> integer(min: 1)
    |> reduce({NParser, :to_date, []})

  #   |> reduce({KindleClippings.Helpers, :parse_date, []})
  # |> unwrap_and_tag(:date)

  # utf8_string([not: ?\s],min: 7)
  time =
    integer(min: 1, max: 2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(" "))
    |> utf8_string([], 2)
    |> reduce({NParser, :to_time, []})

  # |> reduce({KindleClippings.Helpers, :parse_time, []})
  # |> unwrap_and_tag(:time)

  timestamp =
    ignore(eventually(string(", ")))
    |> concat(date)
    |> ignore(string(" "))
    |> concat(time)

  meta_type_and_location =
    ignore(string("- Your "))
    |> unwrap_and_tag(utf8_string([not: ?\s], min: 1), :type)
    |> ignore(string(" on "))
    # |> reduce({KindleClippings.Helpers, :trim_location,[]}), :where)
    |> unwrap_and_tag(reduce(utf8_string([not: ?|], min: 1), {NParser, :trim, []}), :where)
    |> ignore(string("|"))

  meta_absolute_location =
    ignore(string(" Location "))
    |> unwrap_and_tag(utf8_string([not: ?\s], min: 1), :location)
    |> ignore(string(" |"))

  meta_line =
    meta_type_and_location
    |> optional(meta_absolute_location)
    |> concat(timestamp)

  # |> reduce({KindleClippings.Helpers, :parse_metaline,[]})

  clipping_end = string("==========\r\n")

  clipping =
    unwrap_and_tag(line, :title)
    |> ignore(eol)
    |> concat(meta_line)
    |> ignore(double_eol)
    # content
    |> concat(unwrap_and_tag(line, :content))
    |> ignore(eol)
    |> reduce({NParser, :to_clipping, []})

  clippings =
    clipping
    |> ignore(clipping_end)

  # |> reduce({KindleClippings.Helpers, :clipping_to_map, []})

  defparsec(:parse_clippings, clippings |> repeat())
  defparsec(:parse_clipping, clipping)
  defparsec(:parse_metadata, meta_line)
  defparsec(:parse_time, time)

  def trim([str]), do: String.trim(str)

  def to_date([month, day, year]),
    do: {:date, %Date{year: year, month: Helpers.month_to_number(month), day: day}}

  def to_time([hour, minutes, seconds, "PM"]),
    do: {:time, %Time{hour: hour + 12, minute: minutes, second: seconds}}

  def to_time([hour, minutes, seconds, "AM"]),
    do: {:time, %Time{hour: hour, minute: minutes, second: seconds}}

  def null_string(str), do: if(length(str) == "", do: nil, else: str)
  def to_clipping(keywords), do: struct!(Clipping, keywords)
end
