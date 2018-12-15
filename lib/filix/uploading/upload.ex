defmodule Filix.Uploading.Upload do
  @moduledoc """
  Rules and behavior of an upload.
  """
  alias __MODULE__
  alias Filix.Uploading.Commands.RequestUpload
  alias Filix.File
  use TypedStruct

  @type upload_status() ::
    :requested
    | :storage_resources_prepared
    | :uploading
    | :complete
    | :on_hold
    | :cancelled

  typedstruct do
    field :file, File.t()
    field :signed_url, String.t()
    field :status, upload_status(), default: :requested
    field :upload_progress, non_neg_integer(), default: 0
    field :storage_provider, atom()
  end

  def new(%RequestUpload{} = command) do
    %Upload{
      file: File.new(command),
      status: :requested,
      upload_progress: 0,
    }
  end

  # def check_status(%Upload{upload_progress: progress} = upload, :update_upload_progress) do
  #   cond do
  #     (progress >= 100)                -> %Upload{ upload | status: :complete, upload_progress: 100}
  #     (progress > 0 && progress < 100) -> %Upload{ upload | status: :uploading}
  #   end
  # end

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
  def set_state(%Upload{status: :uploading} = upload, :uploading, progress) do
    %Upload{ upload | status: :uploading}
  end
  def set_state(%Upload{status: :uploading} = upload, :complete), do:
    %Upload{ upload | status: :uploading}
end
