defmodule Filix.Events.FileDeleted do
  @moduledoc """
  Emitted when a File is deleted from a Storage Provider.
  """
  use TypedStruct

  typedstruct do
    field :file_id, String.t()
    field :storage_provider, module()
    field :deleted_on, DateTime.t()
  end
end
