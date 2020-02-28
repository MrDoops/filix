defmodule Filix.Upload do
  @moduledoc """
  Representation, rules and behavior of a Filix File Upload.
  """
  alias __MODULE__
  alias Filix.{
    Commands.RequestUpload,
    Events.UploadProgressed,
    File,
    Upload,
  }
  use TypedStruct

  @type upload_status() ::
    :requested
    | :storage_resources_prepared
    | :uploading
    | :complete
    | :cancelled

  typedstruct do
    field :file, File.t()
    field :signed_url, String.t()
    field :status, upload_status(), default: :requested
    field :progress, 0..100, default: 0
    field :storage_provider, atom()
  end

  def new(%RequestUpload{} = command) do
    %Upload{
      file: File.new(command),
      status: :requested,
      progress: 0,
      storage_provider: command.storage_provider,
    }
  end

  def cancel(%Upload{} = upload), do: %Upload{upload | status: :cancelled}

  def progress(%Upload{} = upload, progress) when is_integer(progress) do
    %Upload{upload | progress: progress, status: status_from_progress(progress)}
  end

  def prepare_storage_resources(%Upload{} = upload) do
    case upload.storage_provider.request_upload(upload.file) do
      {:ok, url} -> %Upload{ upload | status: :storage_resources_prepared, signed_url: url}
      _ -> {:error, :error_occurred_preparing_signed_url}
    end
  end

  defp status_from_progress(progress) do
    cond do
      (progress >= 100)                -> :complete
      (progress > 0 && progress < 100) -> :uploading
    end
  end

  def can_request_url?(%Upload{signed_url: url}) when not is_nil(url), do: {:error, :url_already_prepared}
  def can_request_url?(%Upload{signed_url: nil}), do: :ok

  def set_state(%Upload{status: :requested} = upload, :storage_resources_prepared), do:
    %Upload{ upload | status: :storage_resources_prepared}
  def set_state(%Upload{status: :storage_resources_prepared} = upload, :uploading), do:
    %Upload{ upload | status: :uploading}
end
