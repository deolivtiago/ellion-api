defmodule EllionCore.Auth.Users.User.Authenticate do
  @moduledoc false

  import Ecto.Changeset

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    with {:ok, %User{verified?: false} = user} <- verify_credentials(attrs) do
      user
      |> change()
      |> add_error(:email, "must be verified")
      |> then(&{:error, &1})
    end
  end

  defp verify_credentials(%{email: email, password: password}) do
    user = Repo.get_by(User, email: email)

    if valid_password?(user, password) do
      {:ok, user}
    else
      %User{}
      |> change()
      |> add_error(:email, "is incorrect")
      |> add_error(:password, "is incorrect")
      |> then(&{:error, &1})
    end
  end

  defp valid_password?(%User{password: hash}, password), do: Argon2.verify_pass(password, hash)
  defp valid_password?(nil, _password), do: Argon2.no_user_verify()
end
