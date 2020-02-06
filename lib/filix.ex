defmodule Filix do
  @moduledoc """
  Filix is a pluggable File Management tool for uploading, moving, static files.

  Filix requires adapters that implement various behaviours it needs to work properly.

  `Persistence` : Persistence Behaviour Filix uses to create, update, and tag files. In most cases you'll use something like Ecto and Postgres.
  `Query` : Query Behaviour used to fetch, find, and serve persisted files.
  `EventMessaging` : Filix Messaging behaviour used to integrate custom event handlers to Filix interactions.

  Filix also requires a Storage Provider adapter when making upload requests so it can
    request files to upload.

  How should Filix's adapters be configured?

    I like the idea of operations as data with all the necessary config being prepared ahead of time.

    We could use an Operation based approach where the Filix service is responsible for defaults that change infrequently
    like Peristence, Query, and Event Messaging. Filix will execute operations to the service running by module name.

    ```elixir
    {:ok, _filix_supervisor_pid} = Filix.start_link(MyAppsFilixService, [
      persistence: MyAppsPersistenceImpl,
      query: MyAppsQueryImpl,
      event_messaging: MyAppsMessagingImpl,
      storage_provider: FilixS3Adapter.new(
        host_name: System.get_env("AWS_S3_HOST"),
        access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
        secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
        region: System.get_env("AWS_REGION"),
        bucket_name: "filix_example_bucket",
      )
    ])

    {:ok, upload_request} = Filix.RequestUpload.new(
      name: "mountain_pic_1",
      size: 9000,
      type: "JPG",
      tags: ["images", "mountain", "hike"]
    )
    ```
  """
  alias Filix.{
    Commands.RequestUpload,
    Runtime.UploadProcess,
    Runtime.UploadSupervisor,
    Runtime.ServiceManager,
    File,
  }
  import Norm

  @doc """
  Used to start a Filix Service under a supervisor.

  Expected configuration:

  * `name` : Atom / Module name that is used to identify supervised processes spawned by Filix
  * `query` : Module that implements the Filix.Query behaviour
  * `persistence` : Module that implements the Filix.Persistence behaviour
  * `event_messaging` : Module that implements the Filix.EventMessaging behaviour
  * `storage_provider` : Default module that implements the Filix.StorageProvider behaviour. Overridable in Filix commands.

  Invalid configuration will result in an error.
  """
  def child_spec(config) do
    with {:ok, _config} <- validate_config(config) do
      ServiceManager.start_link(config)
    else
      error -> error
    end
  end

  defp validate_config(config) do
    conform(config, valid_config())
  end

  defp valid_config, do: schema(%{
    name: spec(is_atom()),
    query: spec(is_atom()),
    persistence: spec(is_atom()),
    event_messaging: spec(is_atom()),
    storage_provider: spec(is_atom()),
  })

  def request_upload(params) do
    RequestUpload.new(params)
  end

  def update_upload_progress(upload_id, progress)
  when is_integer(progress) do
    UploadProcess.update_progress(upload_id, progress)
  end

  def cancel(upload_id) do
    UploadProcess.cancel_upload(upload_id)
  end
end
