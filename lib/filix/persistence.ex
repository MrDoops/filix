defmodule Filix.Persistence do
  @moduledoc """
  What a Filix Persistence layer must implement.

  Defines how Files and Tags are created, updated, and deleted.

  Should work in tandem with a Query implementation so the default capabilities of managing files by Filix are possible.

  If you'd like to persist a log of events that can be done by handling events published to the EventHandler implementation.

  You can also build your own projected read-model based on the events published to the EventHandler.
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
