defmodule Kindle.Clippings.Parser.RegexParser do
  @moduledoc """
  Provides implementation of a Kindle Clippings file ("MyClippings.txt") parser using regular expressions.
  """
  @behaviour Kindle.Clippings.Parser

  import Kindle.Clippings.Parser.RegexParser.Helpers


  @impl Kindle.Clippings.Parser
  def parse(str, opts\\[]) do
    options =
    [parallel: false]
    |> Keyword.merge(opts)

    str
    |> String.splitter("==========\r\n", trim: true)
    |> parse_entries(parallel: options[:parallel])

  end


  defp parse_entries(entries, parallel: false), do: entries |> Enum.map(&parse_entry/1)


  defp parse_entries(entries, parallel: :flow)  do
    entries
    |> Flow.from_enumerable()
    |> Flow.map(&parse_entry/1)
    |> Enum.to_list()
  end

  defp parse_entries(entries, parallel: :asyncstream) do
    chunk_size = entries |> Enum.to_list() |> length() |> div(System.schedulers_online())

    entries
    |> Stream.chunk_every(chunk_size)
    |> Task.async_stream(fn chunk -> chunk |> Enum.map(&parse_entry/1) end,
      ordered: false,
      timeout: :infinity
    )
    |> Enum.to_list()
  end
end
