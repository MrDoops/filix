defmodule Filix.Runtime.ServiceManager do
  @moduledoc """
  Responsible for holding default configuration and ets tables used by Upload Processes.

  Accepts commands to change configuration at runtime.

  When an upload process is started, unless overrides of adapters are specified, the `fetch_config/1` is used to get rest of the adapters.

  TODO:

  * State here is node-local, we'll need to determine a tenable distribution strategy for both config and upload monitoring across nodes.
    * We might should separate concerns of config and the Upload Monitor as the upload progress is frequently updated wheras the config rarely changes.
    * Upload Monitoring: High Read High Write - eventual consistency is fine
    * Config: High Read, rare write - availability most important (consider logic to refetch config, if changed, upon adapter specific failures for uploads)
  """
  use GenServer

  def start_link(%{name: service_name} = config) do
    GenServer.start_link(
      __MODULE__,
      config,
      name: Module.concat(__MODULE__, service_name)
    )
  end

  def init(config) do
    state = setup_state_from_config(config)
    {:ok, state}
  end

  def active_uploads(service_name) do
    :ets.tab2list(upload_monitor_table_name(service_name))
  end

  def notify_of_active_upload(service_name, upload) do
    :ets.insert(upload_monitor_table_name(service_name), {upload.id, upload})
  end

  defp setup_state_from_config(%{name: service_name} = config) do
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
