defmodule Kindle do
  @moduledoc """
  Provides various Kindle related functionality.
  """

  @doc """
  Parses text containing Kindle Clippings (MyClippings.txt).

  ## Parameters

  * `clippings`: string containing Clippings as exported from kindle via MyClippings.txt
  * `parser_implementation` : module name implementing Clippings.Parser behaviour. There currently two implementations (RegexParser and NimbleParser).
  * `opts` : keyword list with parameters to be passed to the Parser implementation.

  ## Options

  `parallel`: allows different options for parallel parsing of entries. Using parallel processing is around 2x faster than in single process.

    + `false` : uses single process.
    + `:flow` : uses [Flow](https://hex.pm/packages/flow) package for parallel processing.
    + `:asyncstream` : uses `Task.asyncstream()` for parallel processing.

  ## Examples

  iex> Kindle.parse_clippings("The Selfish Gene\\r\\n\- Your Highlight on Location 1600-1602 | Added on Monday, February 9, 2015 6:33:40 PM\\r\\n\\r\\some highlight\\r\\n==========\\r\\n")

  [ok: %Kindle.Clippings.Clipping{content: "\r ome highlight", date: ~D[2015-02-09], location: nil, time: ~T[18:33:40], title: "The Selfish Gene", type: "Highlight", where: "Location 1600-1602"}]

  ## Usage

  ```elixir
  "./MyClippings.txt" |> File.read!() |> parse_clippings()
  ```
  ```elixir
  "./MyClippings.txt" |> File.read!() |> parse_clippings(Kindle.Clippings.Parser.RegexParser, parallel: false)
  ```
  ```elixir
  "./MyClippings.txt" |> File.read!() |>  parse_clippings(Kindle.Clippings.Parser.RegexParser, parallel: :flow)
  ```
  ```elixir
   "./MyClippings.txt" |> File.read!() |> parse_clippings(Kindle.Clippings.Parser.RegexParser, parallel: :asyncstream)
    ```



  """
  @spec parse_clippings(clippings :: String.t(), parser_module :: atom, [...]) :: [
          {:ok, Kindle.Clippings.Clipping} | {:error, term}
        ]
  def parse_clippings(
        clippings,
        parser_implementation \\ Kindle.Clippings.Parser.RegexParser,
        opts \\ [parallel: :flow]
      )
      when is_bitstring(clippings),
      do: parser_implementation.parse(clippings, opts)
end
