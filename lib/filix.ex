defmodule Filix do
  @moduledoc """
  Client facing API for core Filix functionality.
  """
  alias Filix.Uploading

  defdelegate request_upload(params), to: Uploading
end
