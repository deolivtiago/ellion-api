defmodule EllionWeb.AuthController.Refresh do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.UserTokens

  defparams :refresh do
    required(:refresh_token, :string, trim: true)
  end

  def handle(params) do
    params
    |> validate_params()
    |> verify_token()
    |> create_tokens()
  end

  defp validate_params(params), do: validate(:refresh, params)

  defp verify_token({:ok, %{refresh_token: token}}),
    do: UserTokens.verify_user_token(token, :refresh)

  defp verify_token({:error, changeset}), do: {:error, changeset}

  defp create_tokens({:ok, user_token}) do
    with {:ok, access_token} <- UserTokens.create_user_token(user_token.user, :access),
         {:ok, refresh_token} <- UserTokens.create_user_token(user_token.user, :refresh) do
      UserTokens.revoke_user_token(user_token)

      Map.new()
      |> Map.put(:access_token, access_token.token)
      |> Map.put(:refresh_token, refresh_token.token)
      |> then(&{:ok, &1})
    end
  end

  defp create_tokens({:error, changeset}), do: {:error, changeset}
end
