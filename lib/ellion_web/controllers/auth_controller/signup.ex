defmodule EllionWeb.AuthController.SignUp do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users

  defparams :signup do
    required(:first_name, :string, min: 2, max: 255, squish: true)
    optional(:last_name, :string, max: 255, squish: true)

    required(:email, :string, format: :email, min: 3, max: 160, trim: true)
    required(:password, :string, format: :password, min: 6, max: 72, trim: true)

    optional(:avatar_url, :string, format: :url, max: 255)
    optional(:role, :enum, values: ~w(user admin))
  end

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> create_user()
  end

  defp validate_params(params), do: validate(:signup, params)

  defp create_user({:ok, user_attrs}), do: Users.create_user(user_attrs)
  defp create_user({:error, changeset}), do: {:error, changeset}
end
