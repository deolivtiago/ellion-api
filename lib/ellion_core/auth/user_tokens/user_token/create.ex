defmodule EllionCore.Auth.UserTokens.UserToken.Create do
  @moduledoc false
  import Ecto.Changeset

  alias EllionCore.Auth.Users.User
  alias EllionCore.Auth.UserTokens.UserToken
  alias EllionCore.JsonWebToken
  alias EllionCore.Repo

  @doc false
  def call(%User{id: id}, token_type) when is_atom(token_type) do
    changeset = changeset(id, token_type)

    with {:ok, user_token} <- Repo.insert(changeset) do
      user_token
      |> Repo.preload(:user)
      |> then(&{:ok, &1})
    end
  end

  defp changeset(sub, typ) do
    payload =
      Map.new()
      |> Map.put(:sub, sub)
      |> Map.put(:typ, typ)

    case JsonWebToken.from_payload(payload) do
      {:ok, jwt} ->
        UserToken.changeset(jwt)

      {:error, _changeset} ->
        %UserToken{}
        |> change(%{type: typ, user_id: sub})
        |> add_error(:token, "can't be signed")
    end
  end
end
