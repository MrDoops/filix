defmodule Filix.Uploading.Uploader do
  @moduledoc """
  Manages the complexity of uploading a file by tracking the state of an uploading file to a storage provider.

  Commands:
    :upload_progress
    :reinitiate_upload
    :cancel_upload
    :upload_status

  This should be initialized with the Storage Provider.
  """
  use GenServer

  alias Filix.File
  alias Filix.Uploading.{
    Upload,
    Commands.RequestUpload,
  }

  # Client

  def start_link(%RequestUpload{} = command) do
    GenServer.start_link(
      __MODULE__,
      {:request_upload, command}
    )
  end
  def start_link(_), do: :invalid_command

  def init(command), do: {:ok, command, {:continue, :init}}

  def handle_continue(:init, command) do
    {:noreply, command}
  end

  def cancel_upload(file_id) do
    GenServer.call(file_id, :cancel_upload)
  end

  def update_progress(file_id, progress) when is_integer(progress) do
    GenServer.cast(file_id, {:update_upload_progress, progress})
  end

  def status(file_id) do
    GenServer.call(file_id, :status)
  end

  @doc """
  Should fetch a new signed_url should the original expire.

  If possible this should utilize existing partial uploads - but may need to restart upload.
  """
  def reinitiate_upload(file_id) do
    GenServer.call(file_id, :reinitiate_upload)
  end

  # Server callbacks

  # TODO: use default configured storage provider or parse option from command.
  # Handle error for storage_provider authentication?
  def handle_call(:request_upload, _from, %RequestUpload{} = command) do
    upload   = Upload.new(command)
    provider = command.storage_provider || Application.get_env(:filix, :default_storage_provider)

    case provider.setup_storage_resources(upload) do
      {:ok, url} ->
        {:reply, {:ok, url}, Upload.set_state(upload, :storage_resources_prepared)}

      {:error, _} = error ->
        {:reply, error, upload}
    end
  end

  def handle_cast({:update_upload_progress, progress}, %Upload{} = upload) do
    {:no_reply, %Upload{ upload |
        upload_progress: progress,
        status: Upload.status_from_progress(upload),
      }
    }
  end

  def handle_cast(:cancel_upload, _from, file) do
    # destroy storage resources
    # publish cancelled event
    # exit process
  end

end
