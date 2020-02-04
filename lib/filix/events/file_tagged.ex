defmodule Filix.Events.FileTagged do
  @moduledoc """


  """
  use TypedStruct

  typedstruct do
    field :upload_id, String.t()
    field :progress, 0..100
  end
end
