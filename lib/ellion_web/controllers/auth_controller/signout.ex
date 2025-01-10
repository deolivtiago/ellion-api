defmodule EllionWeb.AuthController.SignOut do
  @moduledoc false
  use Goal

  alias EllionCore.Auth.UserTokens

  defparams :signout do
    optional(:access_token, :string)
    optional(:refresh_token, :string)
  end

  @doc false
  def handle(params) do
    params
    |> validate_params()
    |> revoke_tokens()
  end

  defp validate_params(params), do: validate(:signout, params)

  defp revoke_tokens({:ok, auth}) do
    tokens = Map.values(auth)

    UserTokens.list_user_tokens()
    |> Enum.filter(&Enum.member?(tokens, &1.token))
    |> Enum.map(&UserTokens.revoke_user_token/1)
    |> Enum.filter(&match?({:ok, _}, &1))
    |> Enum.map(&elem(&1, 1))
  end

  defp revoke_tokens({:error, changeset}), do: {:error, changeset}
end
