defmodule EllionCore.Auth.UserTokens do
  @moduledoc """
  The `Auth.UserTokens` context
  """

  alias EllionCore.Auth.UserTokens.UserToken

  @doc ~S"""
  Lists all `UserToken`s.

  ## Examples

      iex> list_user_tokens()
      [%UserToken{}, ...]

  """
  defdelegate list_user_tokens, to: UserToken.List, as: :call

  @doc ~S"""
  Creates an `UserToken`.

  ## Examples

      iex> create_user_token(user, token_type)
      {:ok, %UserToken{}}

      iex> create_user_token(bad_user, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user_token(user, token_type), to: UserToken.Create, as: :call

  @doc ~S"""
  Verifies an `UserToken`.

  ## Examples

      iex> verify_user_token(token, token_type)
      {:ok, %UserToken{}}

      iex> verify_user_token(bad_token, token_type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_user_token(token, token_type), to: UserToken.Verify, as: :call

  @doc ~S"""
  Revokes an `UserToken`.

  ## Examples

      iex> revoke_user_token(user_token)
      {:ok, %UserToken{}}

      iex> revoke_user_token(invalid_user_token)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate revoke_user_token(user_token), to: UserToken.Revoke, as: :call
end
