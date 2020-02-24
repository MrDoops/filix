defmodule Filix.Runtime.UploadSupervisor do
  @moduledoc """
  Dynamic Supervisor responsible for spawning uploaders upon request.
  """
  use DynamicSupervisor
  alias Filix.Runtime.UploadProcess

  def start_link(service_name) do
    DynamicSupervisor.start_link(__MODULE__, [], name: Module.concat(__MODULE__, service_name))
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def find_upload_process(service_name, upload_id) do
    UploadProcess.via(service_name, upload_id)
    |> GenServer.whereis()
  end

  def is_upload_process_running?(service_name, upload_id) do
    case find_upload_process(service_name, upload_id) do
      nil -> false
      _pid_or_name -> true
    end
  end

  def stop_upload_process(service_name, upload_id) do
    case find_upload_process(service_name, upload_id) do
      nil -> {:error, :process_not_active}
      {_, _node} -> :error
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end
end
