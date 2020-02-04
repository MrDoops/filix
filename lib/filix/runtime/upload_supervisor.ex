defmodule Filix.Runtime.UploadSupervisor do
  @moduledoc """
  Dynamic Supervisor responsible for spawning uploaders upon request.
  """
  use DynamicSupervisor
  alias Filix.Uploading.{Commands.RequestUpload, Uploader}

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def find_upload_process(upload_id) do
    upload_id
    |> UploadProcess.via()
    |> GenServer.whereis()
  end

  def is_upload_process_running?(upload_id) do
    case find_upload_process(upload_id) do
      nil -> false
      _pid_or_name -> true
    end
  end

  def stop_upload_process(upload_id) do
    case find_upload_process(upload_id) do
      nil -> {:error, :process_not_active}
      {_, _node} -> :error
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end
