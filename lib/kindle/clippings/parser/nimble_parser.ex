defmodule Kindle.Clippings.Parser.NimbleParser do
  @moduledoc """
  Provides implementation of a Kindle Clippings file ("MyClippings.txt") parser using NimbleParsec library.
  """
  @behaviour Kindle.Clippings.Parser

  alias Kindle.Clippings.Parser.NimbleParser

  @impl Kindle.Clippings.Parser
  def parse(str, opts \\ []) do
    options =
      [parallel: false]
      |> Keyword.merge(opts)

    str
    |> String.splitter("==========\r\n", trim: true)
    |> parse_entries(parallel: options[:parallel])
  end

  defp parse_entries(entries, parallel: false) do
    entries
    |> Enum.map(&parse_entry/1)
  end

  defp parse_entries(entries, parallel: :flow) do
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

  defp parse_entry(entrystr) when is_binary(entrystr) do
    case NimbleParser.Parser.parse_clipping(entrystr) do
      {:ok, [result], "", _, _, _} -> {:ok, result}
      _ -> {:error, entrystr}
    end
  end
end
