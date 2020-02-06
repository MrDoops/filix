defmodule Filix.Commands.RequestUpload do
  @moduledoc """
  Command validation layer for Requesting Uploads.

  Ensures that required file information is specfified.

  Allows optional overrides of the Storage Provider configuration.
  """
  import Norm

  @enforce_keys ~w(name size type tags storage_provider)a
  defstruct [
    :name,
    :size,
    :type,
    :tags,
    :storage_provider,
    :upload_id,
  ]

  @type t() :: %__MODULE__{
    name: String.t(),
    size: integer(),
    type: String.t(),
    tags: nonempty_list(String.t()),
    storage_provider: module(),
    upload_id: String.t(),
  }

  def s, do: schema(%__MODULE__{
    name: spec(is_binary()),
    size: spec(is_integer()),
    type: spec(is_binary()),
    tags: spec(is_list()),
    storage_provider: spec(is_atom()),
    upload_id: spec(is_binary())
  })

  def new(params) do
    struct!(__MODULE__, params)
    |> Map.put(:upload_id, UUID.uuid4())
    |> conform!(s())
  end
end
