defmodule Kindle.Clippings.Clipping do
  @moduledoc """
  Defines a structure to represent a Kindle Clipping.
  """
  defstruct [:title, :content, :where, :location, :date, :time, :type]

  @type t() :: %__MODULE__{
          title: String.t(),
          content: String.t() | nil,
          where: String.t(),
          location: String.t() | nil,
          date: %Date{},
          time: %Time{}
        }
end
