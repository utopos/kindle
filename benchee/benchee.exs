inputs = %{
  "small file" => "data/clippings.txt",
  "very big file" => "data/big_clipping.txt"
}

Benchee.run(
  %{
    "regex_parser_single_processs" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.RegexParser.parse(parallel: false) end,

    "regex_parser_parallel_flow" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.RegexParser.parse(parallel: :flow)  end,
    "regex_parser_task_asyncstream" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.RegexParser.parse(parallel: :asyncstream)  end,
    "nimble_parser_single_process" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.NimbleParser.parse(parallel: false) end,
    "nimble_parser_parallel_flow" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.NimbleParser.parse(parallel: :flow) end,
    "nimble_parser_task_asyncstream" => fn path -> File.read!(path) |> Kindle.Clippings.Parser.NimbleParser.parse(parallel: :asyncstream) end,

  },
  #memory_time: 2,
  inputs: inputs
)
