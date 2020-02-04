defmodule Filix.Events.UploadProgressed do
  @moduledoc """
  Emitted to the configured Event Messaging adapter when
  """
  use TypedStruct

  typedstruct do
    field :upload_id, String.t()
    field :progress, 0..100
  end
end
