defmodule Filix.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Filix.Runtime.UploadSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Filix.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
