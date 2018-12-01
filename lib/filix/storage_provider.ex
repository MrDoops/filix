defmodule Filix.StorageProvider do
  @moduledoc """
  Contract of what a configured Storage Provider must implement.
  """
  alias Filix.Commands.RequestUpload

  @callback request_upload(%RequestUpload{}) :: 
  {:ok, %{signed_url: String.t()} 
  | {:error, String.t()}
end