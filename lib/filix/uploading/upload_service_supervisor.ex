defmodule Filix.Uploading.UploadServiceSupervisor do
  @moduledoc """
  Dynamic Supervisor responsible for spawning uploaders upon request.
  """
  use DynamicSupervisor
  alias Filix.Uploading.{Commands.RequestUpload, Uploader}

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def request_upload(%RequestUpload{} = command) do
    child_spec = {Uploader, command}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

end
