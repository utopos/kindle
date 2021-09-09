defmodule Kindle.Clippings.Parser.RegexParser.HelpersTest do
  use ExUnit.Case
  alias Kindle.Clippings.Clipping
  alias Kindle.Clippings.Parser.RegexParser.Helpers

  doctest Kindle.Clippings.Parser.RegexParser.Helpers

  describe "parse_entry/1" do
    test " with a valid string" do
      str =
        "\uFEFFDziennik Paniczny (Roland Topor)\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\ntesg\r\n"

      result = %Clipping{
        title: "Dziennik Paniczny (Roland Topor)",
        type: "Note",
        where: "page 1",
        location: "9",
        time: %Time{hour: 13, minute: 25, second: 25},
        date: ~D[2014-09-06],
        content: "tesg"
      }

      assert {:ok, result} == Helpers.parse_entry(str)
    end

    test " with empty content" do
      str =
        "\uFEFFDziennik Paniczny (Roland Topor)\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM\r\n\r\n\r\n"

      result = %Clipping{
        title: "Dziennik Paniczny (Roland Topor)",
        type: "Note",
        where: "page 1",
        location: "9",
        time: %Time{hour: 13, minute: 25, second: 25},
        date: ~D[2014-09-06],
        content: ""
      }

      assert {:ok, result} == Helpers.parse_entry(str)
    end

    test "with invalid number of lines and no content" do
      str =
        "\uFEFFDziennik Paniczny (Roland Topor)\r\n- Your Note on page 1 | Location 9 | Added on Saturday, September 6, 2014 1:25:25 PM"

      result = %Clipping{
        title: "Dziennik Paniczny (Roland Topor)",
        type: "Note",
        where: "page 1",
        location: "9",
        time: %Time{hour: 13, minute: 25, second: 25},
        date: ~D[2014-09-06],
        content: ""
      }

      assert {:ok, result} == Helpers.parse_entry(str)
    end

    test " with invalid entry - only one line" do
      str =
        "\uFEFFDziennik Paniczny (Roland Topor)\r\n"
        {status,_} = Helpers.parse_entry(str)
      assert status === :error
    end
  end

  describe "parse_metadata/1" do
    test " with double location line" do
      metastr = "- Your Highlight on page 161 | Location 2462-2465 | Added on Thursday, September 25, 2014 4:11:25 PM"

      result =  {:ok,
      %{
        location: "2462-2465",
        type: "Highlight",
        where: "page 161",
        date: ~D[2014-09-25],
        time: ~T[16:11:25]
      }}

      assert result == Helpers.parse_metadata(metastr)
    end

    test " with single location" do
      metastr = "- Your Highlight on page 161 | Added on Thursday, September 25, 2014 4:11:25 PM"

      result =  {:ok,
      %{
        location: nil,
        type: "Highlight",
        where: "page 161",
        date: ~D[2014-09-25],
        time: ~T[16:11:25]
      }}

      assert result == Helpers.parse_metadata(metastr)
    end

    test "with invalid data (lacks time period)" do
      metastr = "- Your Highlight on page 161 | Added on Thursday, September 25, 2014 4:11:25"

      result = {:error, metastr}
      assert result == Helpers.parse_metadata(metastr)
    end
  end
end
