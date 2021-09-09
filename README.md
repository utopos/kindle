# Kindle

Elixir package to provide Kindle related functionalites.

## Services

- [x] Parsing MyClippings.txt file
- [ ] "Send to kindle"

## Example

```elixir
clippings= 
"The Selfish Gene\\r\\n\- Your Highlight on Location 1600-1602 | Added on Monday, February 9, 2015 6:33:40 PM\\r\\n\\r\\some highlight\\r\\n==========\\r\\n"\
|> Kindle.parse_clippings()

clippings == [
  {:ok, %Kindle.Clippings.Clipping{
    content: "some highlight", 
    date: ~D[2015-02-09],
    location: nil,
    time: ~T[18:33:40], 
    title: "The Selfish Gene", 
    type: "Highlight", 
    where: "Location 1600-1602"}
  ]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kindle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kindle, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kindle](https://hexdocs.pm/kindle).

