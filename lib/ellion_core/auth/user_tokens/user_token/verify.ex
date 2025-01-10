defmodule EllionCore.Auth.UserTokens.UserToken.Verify do
  @moduledoc false
  import Ecto.Changeset

  import Ecto.Query, only: [from: 2]

  alias EllionCore.Auth.UserTokens.UserToken
  alias EllionCore.JsonWebToken
  alias EllionCore.Repo

  @doc false
  def call(token, token_type) when is_atom(token_type) do
    with {:ok, %{claims: %{typ: ^token_type}}} <- JsonWebToken.from_token(token),
         %UserToken{} = user_token <- Repo.get_by(query(), token: token, type: token_type) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    else
      _error ->
        %UserToken{}
        |> change(%{token: token})
        |> add_error(:token, "is invalid")
        |> then(&{:error, &1})
    end
  end

  defp query do
    from ut in UserToken,
      where: ut.expires_at > ^DateTime.utc_now()
  end
end
