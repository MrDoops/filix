defmodule Filix.Persistence do
  @moduledoc """
  What a Filix Persistence layer must implement.
  """
  alias Filix.{File, Tag}

  @type file_id() :: String.t()
  @type tag_name() :: String.t()

  @callback create_file(File.t()) ::
    {:ok, File.t()}
    | {:error, String.t()}

  @callback tag_file(file_id, list(Tag.t()) | Tag.t()) ::
    {:ok, File.t()}
    | {:error, String.t()}

  @callback delete_file(file_id) :: :ok | {:error, String.t()}

  @callback remove_tag(tag_name) :: :ok | {:error, String.t()}
end
