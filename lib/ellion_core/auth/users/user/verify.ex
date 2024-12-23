defmodule EllionCore.Auth.Users.User.Verify do
  @moduledoc false

  alias EllionCore.Auth.UserEmails
  alias EllionCore.Auth.Users.User

  @doc false
  def call(%User{} = user, type) do
    user
    |> User.new_verification_code()
    |> then(&UserEmails.send_verification_code(user, type, &1))
  end
end
