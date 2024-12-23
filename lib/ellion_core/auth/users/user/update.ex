defmodule EllionCore.Auth.Users.User.Update do
  @moduledoc false

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @doc false
  def call(%User{} = user, attrs) when is_map(attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
