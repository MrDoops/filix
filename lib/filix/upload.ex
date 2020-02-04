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

  def new(%RequestUpload{} = command, signed_url) do
    %Upload{
      file: File.new(command),
      status: :requested,
      progress: 0,
      signed_url: signed_url,
    }
  end

  def cancel(%Upload{} = upload), do: %Upload{upload | status: :cancelled}

  def progress(%Upload{} = upload, progress) when is_integer(progress) do
    %Upload{upload | progress: progress, status: status_from_progress(progress)}
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
  def set_state(%Upload{status: :uploading} = upload, :uploading, progress) do
    %Upload{ upload | status: :uploading}
  end
  def set_state(%Upload{status: :uploading} = upload, :complete), do:
    %Upload{ upload | status: :uploading}
end
