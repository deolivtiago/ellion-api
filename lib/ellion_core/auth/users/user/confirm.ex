defmodule EllionCore.Auth.Users.User.Confirm do
  @moduledoc false

  import Ecto.Changeset

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @doc false
  def call(%User{} = user, code) when is_binary(code) do
    if User.valid_verification_code?(user, code) do
      user
      |> User.changeset(%{verified?: true})
      |> Repo.update!()
      |> then(&{:ok, &1})
    else
      {user, %{code: :string}}
      |> change(%{code: code})
      |> add_error(:code, "is invalid")
      |> then(&{:error, &1})
    end
  end
end
