defmodule Filix.Runtime.ServiceManager do
  @moduledoc """
  Responsible for holding default configuration and ets tables used by Upload Processes.

  Accepts commands to change configuration at runtime.

  When an upload process is started, unless overrided specified it fetches configuration from state managed here.
  """
  use GenServer

  def start_link(%{name: service_name} = config) do
    GenServer.start_link(
      __MODULE__,\
      config,
      name: Module.concat(__MODULE__, service_name)
    )
  end

  def init(config) do
    state = state_from_config(config)
    {:ok, state}
  end

  defp state_from_config(%{name: service_name} = config) do
    config_table_name = config_table_name(service_name)

    state = %{ config |
      upload_monitor_table: :ets.new(
        upload_monitor_table_name(service_name),
        [:named_table, :set, :public, read_concurrency: true]
      ),
      config_table: :ets.new(
        config_table_name,
        [:named_table, :set, :public, read_concurrency: true]
      ),
    }

    :ets.insert(config_table_name, {:config, config})

    # Enum.map(config, fn {k, v} ->
    #   :ets.insert(config_table_name, {k, v})
    # end)

    state
  end

  defp config_table_name(service_name), do: Module.concat(service_name, Config)

  defp upload_monitor_table_name(service_name), do: Module.concat(service_name, UploadMonitor)

  def fetch_config(service_name) do
    [{_, config}] = :ets.lookup(config_table_name(service_name), :config)
    config
  end
end
