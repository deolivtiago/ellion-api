defmodule EllionCore.Auth.Users.User do
  @moduledoc """
  The `User` schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @totp_opts [period: 300]

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    field :email, :string
    field :password, :string, redact: true

    field :avatar_url, :string, default: ""
    field :role, Ecto.Enum, values: ~w(user admin)a, default: :user

    field :totp_secret, :binary, autogenerate: {NimbleTOTP, :secret, []}, redact: true
    field :verified?, :boolean, source: :is_verified, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user \\ %__MODULE__{}, attrs) when is_map(attrs) do
    required_fields = ~w(first_name email password)a
    optional_fields = ~w(last_name avatar_url role totp_secret verified?)a

    user
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> unique_constraint(:id, name: :users_pkey)
    |> validate_length(:first_name, min: 2, max: 255)
    |> validate_length(:last_name, max: 255)
    |> unique_constraint(:email, name: :users_email_index)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 3, max: 160)
    |> validate_format(:email, ~r/^[.!?@#$%^&*_+a-z\-0-9]+[@][._+\-a-z0-9]+$/)
    |> validate_length(:password, min: 6, max: 72)
    |> validate_length(:password, max: 72, count: :bytes)
    |> validate_format(:password, ~r/[0-9]/, message: "must have number(s)")
    |> validate_format(:password, ~r/[a-z]/, message: "must have lower case character(s)")
    |> validate_format(:password, ~r/[A-Z]/, message: "must have upper case character(s)")
    |> validate_format(:password, ~r/[.!?@#$%^&*_+\-]/, message: "must have symbol(s)")
    |> update_change(:password, &Argon2.hash_pwd_salt/1)
    |> update_change(:avatar_url, &String.downcase/1)
    |> validate_length(:avatar_url, max: 255)
  end

  @doc ~S"""
  Returns a verification code for the given user.

    ## Examples

        iex> new_verification_code(user)
        "123456"
  """
  def new_verification_code(%__MODULE__{totp_secret: totp_secret}, opts \\ @totp_opts),
    do: NimbleTOTP.verification_code(totp_secret, opts)

  @doc ~S"""
  Validates the given verification code for an user.

    ## Examples

        iex> valid_verification_code(user, code)
        true

  """
  def valid_verification_code?(%__MODULE__{totp_secret: totp_secret}, code, opts \\ @totp_opts)
      when is_binary(code),
      do: NimbleTOTP.valid?(totp_secret, code, opts)
end
