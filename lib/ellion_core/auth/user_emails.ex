defmodule EllionCore.Auth.UserEmails do
  @moduledoc """
  The `UserEmails` context.
  """
  alias EllionCore.Auth.UserEmails.VerificationCode

  defdelegate send_verification_code(user, type, code), to: VerificationCode.Send, as: :call
end
