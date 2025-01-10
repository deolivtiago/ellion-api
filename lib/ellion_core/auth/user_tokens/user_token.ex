defmodule EllionCore.Auth.UserTokens.UserToken do
  @moduledoc """
  The `UserToken` schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias EllionCore.Auth.Users.User
  alias EllionCore.JsonWebToken

  @valid_uuid ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "user_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime

    field :type, Ecto.Enum, values: ~w(access refresh)a

    belongs_to :user, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(%JsonWebToken{token: token, claims: claims}) do
    Map.new()
    |> Map.put(:token, token)
    |> Map.put(:id, claims.jti)
    |> Map.put(:type, claims.typ)
    |> Map.put(:user_id, claims.sub)
    |> Map.put(:expires_at, DateTime.from_unix!(claims.exp, :second))
    |> changeset()
  end

  def changeset(user_token \\ %__MODULE__{}, params) when is_map(params) do
    required_fields = ~w(id token expires_at type user_id)a

    user_token
    |> cast(params, required_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:id, name: :user_tokens_pkey)
    |> update_change(:id, &String.downcase/1)
    |> validate_format(:id, @valid_uuid)
    |> update_change(:user_id, &String.downcase/1)
    |> validate_format(:user_id, @valid_uuid)
    |> unique_constraint(:token)
    |> assoc_constraint(:user)
  end
end
