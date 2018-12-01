defmodule Filix.Uploading.Commands.RequestUpload do
  @moduledoc """
  Command validation layer for Requesting Uploads
  """
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(name size type tags)a
  @optional_fields ~w(storage_provider)a

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :name, :string
    field :size, :integer
    field :type, :string
    field :tags, {:array, :string}
    field :storage_provider, :string
    field :requested_on, :utc_datetime
  end

  def new(params) do
    command = changeset(params)
    case command.valid? do
      true  -> {:ok, apply_changes(command)}
      false -> {:error, command.errors}
    end
  end

  defp changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> Map.put_new(:requested_on, DateTime.utc_now())
  end
end
