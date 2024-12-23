defmodule EllionCore.Auth.Users.User.Delete do
  @moduledoc false

  alias EllionCore.Auth.Users.User
  alias EllionCore.Repo

  @opts [stale_error_field: :id, stale_error_message: "not found"]

  @doc false
  def call(%User{} = user), do: Repo.delete(user, @opts)
end
