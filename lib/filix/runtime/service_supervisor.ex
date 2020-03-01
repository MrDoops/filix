defmodule Filix.Runtime.ServiceSupervisor do
  @moduledoc """
  Top level supervisor for a Filix Service.
  """
  use Supervisor

  alias Filix.Runtime.{
    UploadSupervisor,
    ServiceManager,
  }

  @impl true
  def child_spec(%{name: service_name} = config) do
    %{
      id: Module.concat(__MODULE__, config[:name]),
      start: {Filix.Runtime.ServiceSupervisor, :start_link, [config]},
      type: :supervisor
    }
  end

  @impl true
  def start_link(config) do
    sup_name = Module.concat(__MODULE__, config[:name])

    Supervisor.start_link(__MODULE__, config, name: sup_name)
  end

  @impl true
  def init(%{name: service_name} = config) do
    children = [
      {ServiceManager, config},
      {Registry, name: Module.concat(Filix.UploadRegistry, service_name), keys: :unique},
      {UploadSupervisor, service_name},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
