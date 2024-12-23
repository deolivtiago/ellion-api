defmodule EllionCore.Auth.UserEmails.VerificationCode do
  @moduledoc """
  The `VerificationCode` email.
  """
  alias EllionCore.Auth.Users.User
  alias Swoosh.Email

  @verification_types ~w(confirm_account reset_password update_email)a

  @doc ~S"""
  Creates a new `Swoosh.Email` to verify an user.

  ## Example

      iex> new(user, type, code)
      %Swoosh.Email{}

  """
  def new(%User{} = user, type, code) when type in @verification_types and is_binary(code) do
    text_content = instructions_for(type, user.first_name, code)

    Email.new()
    |> Email.from({"Ellion Platform", "ellion-platform@mail.com"})
    |> Email.to({user.first_name, user.email})
    |> Email.subject("Verification Code")
    |> Email.text_body(text_content)
  end

  defp instructions_for(:confirm_account, first_name, code) do
    """

    ==============================

    Hi #{first_name},

    Please, access your app and enter the code below to confirm your account:

    #{code}

    If you didn't create an account with us, please ignore this.

    ==============================
    """
  end

  defp instructions_for(:reset_password, first_name, code) do
    """

    ==============================

    Hi #{first_name},

    Please, access your app and enter the code below to reset your password:

    #{code}

    If you didn't request this change, please ignore this.

    ==============================
    """
  end

  defp instructions_for(:update_email, first_name, code) do
    """

    ==============================

    Hi #{first_name},

    Please, access your app and enter the code below to change your email:

    #{code}

    If you didn't request this change, please ignore this.

    ==============================
    """
  end
end
