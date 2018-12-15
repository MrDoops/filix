defmodule Filix.Query do
  @moduledoc """
  Query behaviour to be implemented for standard Filix capabilities.
  """
  alias Filix.{File, Tag}

  @type tag_name() :: String.t()

  @callback list_files() :: {:ok, list(File.t())} | {:error, String.t()}

  @callback list_tags() :: {:ok, list(Tag.t())} | {:error, any()}

  @callback files_of_tag(tag_name) ::
    {:ok, list(File.t())}
    | {:error, any()}

  @callback files_of_tags(list(tag_name)) ::
    {:ok, %{optional(tag_name) => list()}}
    | {:error, any()}
end
