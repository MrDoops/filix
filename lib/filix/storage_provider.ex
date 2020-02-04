defmodule Filix.StorageProvider do
  @moduledoc """
  Contract of what a configured Storage Provider must implement.
  """
  alias Filix.Commands.RequestUpload

  @type file_id() :: binary()
  @type signed_url() :: String.t()

  @callback request_upload(RequestUpload.t()) ::
    {:ok, signed_url()}
    | {:error, signed_url()}

  @callback delete_file(file_id()) ::
    :ok
    | :error
    | {:error, :not_found}
end
