defmodule KindleTest do
  use ExUnit.Case
  doctest Kindle

  test "parse_clippings/3 with valid data" do
  result =  "The Selfish Gene (Richard Dawkins)\r\n- Your Highlight on Location 1600-1602 | Added on Monday, February 9, 2015 6:33:40 PM\r\n\r\nThis is not normally regarded as competition for a resource, but logically it is hard to see why not.\r\n==========\r\n" |> Kindle.parse_clippings()
  expected = [{:ok, %Kindle.Clippings.Clipping{content: "This is not normally regarded as competition for a resource, but logically it is hard to see why not.", date: ~D[2015-02-09], location: nil, time: ~T[18:33:40], title: "The Selfish Gene (Richard Dawkins)", type: "Highlight", where: "Location 1600-1602"}}]
  assert expected == result
  end

end
