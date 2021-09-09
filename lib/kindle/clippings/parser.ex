defmodule Kindle.Clippings.Parser
do
    @moduledoc """
    Parses a Kindle Clipping data.
    """
    alias Kindle.Clippings.Clipping

    @doc """
    Generic function for parsing Kindle Clippings.
    """
    @callback parse(data::String.t(),opts::keyword()) :: [{:ok,%Clipping{}}] | [{:error, reason::term}]
end
