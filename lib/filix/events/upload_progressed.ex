defmodule Filix.Events.UploadProgressed do
  @moduledoc """
  Emitted to the configured Event Messaging adapter when an upload progresses.

  These are lower priority events you might want to deliver with only in-memory guarantees
    through something like Phoenix PubSub to a front-end like Liveview. Ordering isn't as
    important and handling this event is mostly a convenience for monitoring upload progression
    server side.

  Upload Progressed is the only event in Filix that should permit lower priority messaging guarantees. For
    all other events (e.g. FileUploaded) you may have business logic that relies on its delivery,
    so use an appropriate message delivery mechanism like a robust FIFO queue.
  """
  use TypedStruct

  typedstruct do
    field :upload_id, String.t()
    field :progress, 0..100
    field :progressed_at, DateTime.t()
  end
end
