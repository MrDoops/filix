defmodule Filix do
  @moduledoc """
  Filix is a pluggable File Management tool for uploading, moving, static files.

  Filix requires adapters that implement various behaviours it needs to work properly.

  `Persistence` : Persistence Behaviour Filix uses to create, update, and tag files. In most cases you'll use something like Ecto and Postgres.
  `Query` : Query Behaviour used to fetch, find, and serve persisted files.
  `EventMessaging` : Filix Messaging behaviour used to integrate custom event handlers to Filix interactions.

  Filix also requires a Storage Provider

  Filix requires a Storage Provider adapter when making upload requests so it can
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

    {:ok, upload_url} = MyAppsFilixService.execute(upload_request)
    ```
  """
  alias Filix.{
    Commands.RequestUpload,
    Runtime.UploadProcess,
    Runtime.UploadSupervisor,
    File,
  }

  def start_link(name, opts \\ []) do
    with :ok <- validate_persistence(opts),

    do

    end
  end

  def request_upload(params \\ %{}) when is_map(params) do
    with {:ok, command} <- RequestUpload.new(params) do
      command |> UploadProcess.request_upload()
    else
      error -> error
    end
  end

  def update_upload_progress(upload_id, progress)
  when is_integer(progress) do
    UploadProcess.update_progress(upload_id, progress)
  end

  def cancel(upload_id) do
    UploadProcess.cancel(upload_id)
  end
end
