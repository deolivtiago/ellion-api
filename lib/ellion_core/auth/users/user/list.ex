defmodule EllionCore.Auth.Users.User.List do
  @moduledoc false

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @doc false
  def call, do: Repo.all(User)
end
