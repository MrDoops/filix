defmodule Filix.Events.FileTagged do
  @moduledoc """


  """
  use TypedStruct

  typedstruct do
    field :file_id, String.t()
    field :tag, String.t()
    field :tagged_on, DateTime.t()
  end
end
