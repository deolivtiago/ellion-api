defmodule EllionWeb.UserController.Create do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :create_user do
    required(:first_name, :string, min: 2, max: 255, squish: true)
    optional(:last_name, :string, max: 255, squish: true)

    required(:email, :string, format: :email, min: 3, max: 160, trim: true)
    required(:password, :string, format: :password, min: 6, max: 72, trim: true)

    optional(:avatar_url, :string, format: :url, max: 255)
    optional(:role, :enum, values: ~w(user admin), default: :user)
  end

  def handle(params) do
    params
    |> validate_params()
    |> create_user()
  end

  defp validate_params(params), do: validate(:create_user, params)

  defp create_user({:ok, attrs}), do: Users.create_user(attrs)
  defp create_user({:error, changeset}), do: {:error, changeset}
end
