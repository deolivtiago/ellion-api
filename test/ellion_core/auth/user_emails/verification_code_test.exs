defmodule EllionCore.Auth.UserEmails.VerificationCodeTest do
  use ExUnit.Case, async: true

  import EllionCore.Auth.UsersFixtures

  alias EllionCore.Auth.UserEmails.VerificationCode
  alias EllionCore.Auth.Users.User

  setup do
    {:ok, user: build_user()}
  end

  describe "new/3 returns" do
    test "returns a verification code email", %{user: user} do
      code = User.new_verification_code(user)

      assert %Swoosh.Email{} = VerificationCode.new(user, :confirm_account, code)
      assert %Swoosh.Email{} = VerificationCode.new(user, :reset_password, code)
      assert %Swoosh.Email{} = VerificationCode.new(user, :update_email, code)
    end
  end
end
