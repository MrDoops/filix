defmodule Filix.File do
  @moduledoc """
  Return type of Filix file management representing an uploaded file.
  """
  use TypedStruct
  alias Filix.Commands.RequestUpload

  typedstruct do
    field :id, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :size, integer(), enforce: true
    field :type, String.t(), enforce: true
    field :tags, nonempty_list(String.t()), enforce: true
  end

  @spec new(RequestUpload.t()) :: Filix.File.t()
  def new(%RequestUpload{} = command) do
    %__MODULE__{
      id: command.id,
      name: command.name,
      size: command.size,
      type: command.type,
      tags: command.tags,
    }
  end
end
