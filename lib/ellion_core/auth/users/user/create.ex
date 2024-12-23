defmodule EllionCore.Auth.Users.User.Create do
  @moduledoc false

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @doc false
  def call(attrs) when is_map(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end
end
