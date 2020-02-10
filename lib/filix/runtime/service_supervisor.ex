defmodule Filix.Runtime.ServiceSupervisor do
  @moduledoc """
  Top level supervisor for a Filix Service.
  """
  use Supervisor

  alias Filix.Runtime.{
    UploadSupervisor,
    ServiceManager,
  }

  def start_link(config) do
    sup_name = Module.concat(__MODULE__, config[:name])

    Supervisor.start_link(__MODULE__, config, name: sup_name)
  end

  @impl true
  def init(%{name: service_name} = config) do
    children = [
      {ServiceManager, config},
      {Registry, name: Module.concat(Filix.UploadRegistry, service_name), keys: :unique},
      {Filix.Runtime.UploadSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
