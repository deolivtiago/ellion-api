defmodule EllionWeb.AuthController.SignIn do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.Users
  alias EllionCore.Auth.UserTokens

  defparams :signin do
    required(:email, :string, format: :email, min: 3, max: 160, trim: true)
    required(:password, :string, trim: true)
  end

  def handle(params) do
    params
    |> validate_params()
    |> authenticate_user()
    |> create_tokens()
  end

  defp validate_params(params), do: validate(:signin, params)

  defp authenticate_user({:ok, user_attrs}), do: Users.authenticate_user(user_attrs)
  defp authenticate_user({:error, changeset}), do: {:error, changeset}

  defp create_tokens({:ok, user}) do
    with {:ok, access_token} <- UserTokens.create_user_token(user, :access),
         {:ok, refresh_token} <- UserTokens.create_user_token(user, :refresh) do
      Map.new()
      |> Map.put(:access_token, access_token.token)
      |> Map.put(:refresh_token, refresh_token.token)
      |> then(&{:ok, &1})
    end
  end

  defp create_tokens({:error, changeset}), do: {:error, changeset}
end
