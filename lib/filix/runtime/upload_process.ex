defmodule Filix.Runtime.UploadProcess do
  @moduledoc """
  Manages the complexity of uploading a file by tracking the state of an uploading file to a storage provider.

  Commands:
    :upload_progress
    :reinitiate_upload
    :cancel_upload
    :upload_status
  """
  use GenServer

  alias Filix.{
    Upload,
    Commands.RequestUpload,
    Runtime.UploadSupervisor,
    Runtime.ServiceManager,
  }

  def via(service_name, upload_id) when is_binary(upload_id) do
    {:via, Registry, {Module.concat(Filix.UploadRegistry, service_name), {__MODULE__, upload_id}}}
  end

  def child_spec(upload_id) do
    %{
      id: {__MODULE__, upload_id},
      start: {__MODULE__, :start_link, [upload_id]},
      restart: :temporary,
    }
  end

  def start_link(%RequestUpload{} = cmd) do
    GenServer.start_link(
      __MODULE__,
      cmd,
      name: via(cmd.service_name, cmd.upload_id)
    )
  end
  def start_link(_), do: {:error, :invalid_command}

  def start(%RequestUpload{} = cmd) do
    DynamicSupervisor.start_child(
      UploadSupervisor,
      {__MODULE__, cmd}
    )
  end

  def stop(service_name, upload_id) do
    GenServer.stop(via(service_name, upload_id))
  end

  def init(%RequestUpload{} = cmd) do
    {:ok, cmd, {:continue, :init}}
  end

  def handle_continue(:init, %RequestUpload{} = cmd) do
    config = ServiceManager.fetch_config(cmd.service_name)
    {:noreply, Upload.new(cmd)}
  end

  def cancel_upload(service_name, upload_id) do
    GenServer.call(via(service_name, upload_id), :cancel_upload)
  end

  def update_progress(service_name, upload_id, progress) when is_integer(progress) do
    GenServer.cast(via(service_name, upload_id), {:update_upload_progress, progress})
  end

  def status(service_name, upload_id) do
    GenServer.call(via(service_name, upload_id), :status)
  end

  def handle_cast({:update_upload_progress, progress}, %Upload{} = upload) do
    {:noreply, Upload.progress(upload, progress)}
  end

  def handle_call(:cancel_upload, _from, upload) do
    {:reply, :ok, Upload.cancel(upload)}
  end

end
