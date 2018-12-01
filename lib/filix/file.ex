defmodule Filix.File do
  @moduledoc """
  
  """
  use TypedStruct
  alias Filix.Uploading.Commands.RequestUpload

  typedstruct do
    field :id, String.t()
    field :name, String.t(), enforce: true
    field :size, integer(), enforce: true
    field :type, String.t(), enforce: true
    field :url, String.t(), default: nil
    field :status, atom(), default: :upload_requested
    field :upload_progress, non_neg_integer(), default: 0
    field :tags, nonempty_list(String.t()), enforce: true
    field :signed_url, String.t()
  end

  @spec new(RequestUpload.t()) :: Filix.File.t()
  def new(%RequestUpload{} = command) do
    %__MODULE__{
      id: UUID.uuid4(),
      name: command.name,
      size: command.size,
      type: command.type,
      tags: command.tags,
      status: :requested,
    }
  end
end