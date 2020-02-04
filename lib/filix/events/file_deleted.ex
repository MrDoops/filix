defmodule Filix.Events.FileDeleted do
  @moduledoc """
  Emitted when a File is deleted from a Storage Provider.
  """
  use TypedStruct

  typedstruct do
    field :upload_id, String.t()
    field :storage_provider, 0..100
  end
end
