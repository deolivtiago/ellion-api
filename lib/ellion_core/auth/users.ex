defmodule EllionCore.Auth.Users do
  @moduledoc """
  The `Auth.Users` context.
  """

  alias EllionCore.Auth.Users.User

  @doc ~S"""
  Lists all users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  defdelegate list_users, to: User.List, as: :call

  @doc ~S"""
  Gets an user.

  ## Examples

      iex> get_user(field, value)
      {:ok, %User{}}

      iex> get_user(field, bad_value)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate get_user(field, value, opts \\ []), to: User.Get, as: :call

  @doc ~S"""
  Creates an user.

  ## Examples

      iex> create_user(attrs)
      {:ok, %User{}}

      iex> create_user(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate create_user(attrs), to: User.Create, as: :call

  @doc ~S"""
  Updates an user.

  ## Examples

      iex> update_user(user, attrs)
      {:ok, %User{}}

      iex> update_user(user, bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate update_user(user, attrs), to: User.Update, as: :call

  @doc ~S"""
  Deletes an user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(bad_user)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate delete_user(user), to: User.Delete, as: :call

  @doc ~S"""
  Authenticates an user.

  ## Examples

      iex> authenticate_user(attrs)
      {:ok, %User{}}

      iex> authenticate_user(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate authenticate_user(attrs), to: User.Authenticate, as: :call

  @doc ~S"""
  Verifies an user.

  ## Examples

      iex> verify_user(user, type)
      {:ok, %User{}}

      iex> verify_user(user, type)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate verify_user(user, type), to: User.Verify, as: :call

  @doc ~S"""
  Confirms an user.

  ## Examples

      iex> confirm_user(user, code)
      {:ok, %User{}}

      iex> confirm_user(user, bad_code)
      {:error, %Ecto.Changeset{}}

  """
  defdelegate confirm_user(user, code), to: User.Confirm, as: :call
end
