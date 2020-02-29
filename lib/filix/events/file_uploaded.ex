defmodule Filix.Events.FileUploaded do
  @moduledoc """


  """
  use TypedStruct

  typedstruct do
    field :file_id, String.t()
    field :uploaded_on, DateTime.t()
    field :storage_provider, module()
  end
end
