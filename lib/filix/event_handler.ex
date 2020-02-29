defmodule Filix.EventHandler do
  @moduledoc """
  Defines the contract an Event Handler must implement.
  """
  alias Filix.Events.{
    FileUploaded,
    FileTagged,
    UploadProgressed,
    FileDeleted,
  }

  @type event() ::
    FileUploaded.t()
    | FileDeleted.t()
    | FileTagged.t()
    | UploadProgressed.t()

  @callback handle_event(event()) :: :ok
end
