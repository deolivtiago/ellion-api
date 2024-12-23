defmodule EllionCore.Auth.UserEmails.VerificationCode.Send do
  @moduledoc false

  alias EllionCore.Auth.UserEmails
  alias EllionCore.Auth.Users.User
  alias EllionCore.Mailer

  @doc false
  def call(%User{} = user, type, code) do
    user
    |> create_verification_email(type, code)
    |> Mailer.send_email()
  end

  defdelegate create_verification_email(user, type, code),
    to: UserEmails.VerificationCode,
    as: :new
end
