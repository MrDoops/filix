defmodule Filix.Uploading do
  @moduledoc """
  TODO:
    - `Filix.Uploading.request_upload()` should return `{:ok, file}`
    - Utilize registry and via tuples to name Uploader processes by File.id
    - Update progress
    -
  """
  alias Filix.{
    Uploading.Commands.RequestUpload,
    Uploading.UploadServiceSupervisor,
    File,
  }

  def request_upload(params \\ %{}) when is_map(params) do
    with {:ok, command} <- RequestUpload.new(params) do
      command
      |> UploadServiceSupervisor.request_upload()
      |> Map.from_struct()
    else
      {:error, _} = message -> message
    end
  end

  def update_upload_progress(upload_id, progress) when is_integer(progress) do
    # Locate the process in the registry by it's uuid and cast the update upload progress
  end

  def cancel(upload_id) do
    # Find current upload in registry, tell it to cancel
    # Should case where upload has completed be handled as a delete or an error?
  end
end
