defmodule EllionCore.Auth.UserTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EllionCore.Auth.UserTokens` context.
  """
  import EllionCore.JsonWebTokenFixtures

  alias EllionCore.Auth.Users.User
  alias EllionCore.Auth.UserTokens.UserToken
  alias EllionCore.Repo

  @doc """
  Builds a fake `UserToken`

    ## Examples

      iex> build_user_token(user, opts)
      %UserToken{field: value, ...}

  """
  def build_user_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> UserToken.changeset()
    |> Ecto.Changeset.apply_action!(nil)
  end

  @doc """
  Inserts a fake `UserToken`

    ## Examples

      iex> insert_user_token(user, opts)
      %UserToken{field: value, ...}

  """
  def insert_user_token(%User{} = user, opts \\ []) do
    user
    |> build_jwt(opts)
    |> UserToken.changeset()
    |> Repo.insert!()
    |> Repo.preload(:user)
  end
end
