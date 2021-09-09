defmodule Kindle.Clippings.Parser.NimbleParserTest do
  use ExUnit.Case
  doctest Kindle.Clippings.Parser.NimbleParser

  alias Kindle.Clippings.Parser.NimbleParser

  describe "parse/1" do
    test " with single clipping" do
     lines =  "Nimble Parser is Great\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\nThis is my note\r\n==========\r\n"
     assert {:ok,[result],_,_,_,_} = NimbleParser.Parser.parse_clippings(lines)
     expected = %Kindle.Clippings.Clipping{content: "This is my note", date: ~D[2014-09-06], location: "9", time: ~T[13:25:25], title: "Nimble Parser is Great", type: "Note", where: "page 1"}
     assert expected == result

    end

    test " with two clippings" do
      lines =  "Nimble Parser is Great\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\nThis is my note\r\n==========\r\nNimble Parser is Great\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\nThis is my note\r\n==========\r\n"
      assert {:ok,[result,result],_,_,_,_} = NimbleParser.Parser.parse_clippings(lines)
      expected = %Kindle.Clippings.Clipping{content: "This is my note", date: ~D[2014-09-06], location: "9", time: ~T[13:25:25], title: "Nimble Parser is Great", type: "Note", where: "page 1"}
      assert expected == result

     end

     test " with single clipping with no content" do
      lines =  "Nimble Parser is Great\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\n\r\n==========\r\n"
      assert {:ok,[result],_,_,_,_} = NimbleParser.Parser.parse_clippings(lines)
      expected = %Kindle.Clippings.Clipping{content: "", date: ~D[2014-09-06], location: "9", time: ~T[13:25:25], title: "Nimble Parser is Great", type: "Note", where: "page 1"}
      assert expected == result

     end

     test " with single clipping with no location" do
      lines =  "Nimble Parser is Great\r\n- Your Note on page 1 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\nContent\r\n==========\r\n"
      assert {:ok,[result],_,_,_,_} = NimbleParser.Parser.parse_clippings(lines)
      expected = %Kindle.Clippings.Clipping{content: "Content", date: ~D[2014-09-06], location: nil, time: ~T[13:25:25], title: "Nimble Parser is Great", type: "Note", where: "page 1"}
      assert expected == result

     end
  end

  describe "parse_metaline/1" do
    test " with valid 3 parts" do
      line =
        "- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM"

      result = NimbleParser.Parser.parse_metadata(line)

      expected =
        {:ok,
         [
           type: "Note",
           where: "page 1",
           location: "9",
           date: ~D[2014-09-06],
           time: ~T[13:25:25]
         ], "", %{}, {1, 0}, 84}

      assert expected == result
    end

    test " with valid 2 parts" do
      line = "- Your Note on page 1 | Added on Saturday, September 6, 2014 1:25:25 PM"
      result = NimbleParser.Parser.parse_metadata(line)

      assert {:ok, [type: "Note", where: "page 1", date: ~D[2014-09-06], time: ~T[13:25:25]], "",
              %{}, _, _} = result
    end
  end

  describe "parse_time/1" do
    test " with hour represented by one digit" do
      line = "1:25:25 PM"
      result = NimbleParser.Parser.parse_time(line)
      assert {:ok, [{:time, ~T[13:25:25]}], "", %{}, _, _} = result
    end

    test " with hour represented by two digits" do
      line = "11:25:25 AM"
      result = NimbleParser.Parser.parse_time(line)
      assert {:ok, [{:time, ~T[11:25:25]}], "", %{}, _, _} = result
    end
  end
end
