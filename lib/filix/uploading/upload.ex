defmodule Filix.Uploading.Upload do
  @moduledoc """
  Rules and behavior of an upload.
  """
  alias __MODULE__
  alias Filix.Uploading.Commands.RequestUpload
  use TypedStruct

  typedstruct do
    field :file_id, String.t()
    field :name, String.t(), enforce: true
    field :size, integer(), enforce: true
    field :type, String.t(), enforce: true
    field :url, String.t(), default: nil
    field :tags, nonempty_list(String.t()), enforce: true
    field :status, atom(), default: :upload_requested
    field :upload_progress, non_neg_integer(), default: 0
  end

  def new(%RequestUpload{} = command) do
    __MODULE__{
      file_id: UUID.uuid4(),
      name: command.name,
      size: command.size,
      type: command.type,
      tags: command.tags,
      status: :requested,
      upload_progress: 0,
    }
  end

  def check_status(%Upload{upload_progress: progress} = upload, :update_upload_progress) do
    cond do
      (progress >= 100)                -> %Upload{ upload | status: :complete, upload_progress: 100}
      (progress > 0 && progress < 100) -> %Upload{ upload | status: :uploading}
    end
  end

  def status_from_progress(%Upload{upload_progress: progress}) do
    cond do
      (progress >= 100)                -> :complete
      (progress > 0 && progress < 100) -> :uploading
    end
  end

  def set_state(%Upload{status: :requested} = upload, :storage_resources_prepared), do:
    %Upload{ upload | status: :storage_resources_prepared}
  def set_state(%Upload{status: :storage_resources_prepared} = upload, :uploading), do:
    %Upload{ upload | status: :uploading}
  def set_state(%Upload{status: :uploading} = upload, :uploading, progress), do
    %Upload{ upload | status: :uploading}
  end
  def set_state(%Upload{status: :uploading} = upload, :complete), do:
    %Upload{ upload | status: :uploading}
end
