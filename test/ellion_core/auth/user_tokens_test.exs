defmodule EllionCore.Auth.UserTokensTest do
  use EllionCore.DataCase, async: true

  import EllionCore.Auth.UsersFixtures
  import EllionCore.Auth.UserTokensFixtures

  alias Ecto.Changeset
  alias EllionCore.Auth.Users.User
  alias EllionCore.Auth.UserTokens
  alias EllionCore.Auth.UserTokens.UserToken

  setup do
    {:ok, user: insert_user()}
  end

  describe "list_user_tokens/0" do
    test "without user tokens returns an empty list" do
      assert [] == UserTokens.list_user_tokens()
    end

    test "with users returns all users", %{user: user} do
      user_token = insert_user_token(user)

      assert [user_token] == UserTokens.list_user_tokens()
    end
  end

  describe "verify_user_token/2 returns" do
    test "ok when access token is valid", %{user: user} do
      user_token = insert_user_token(user, typ: :access)

      assert {:ok, user_token} == UserTokens.verify_user_token(user_token.token, :access)
    end

    test "ok when refresh token is valid", %{user: user} do
      user_token = insert_user_token(user, typ: :refresh)

      assert {:ok, user_token} == UserTokens.verify_user_token(user_token.token, :refresh)
    end

    test "error when token is invalid" do
      assert {:error, changeset} = UserTokens.verify_user_token("invalid_token", :access)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end

    test "error when access token has a different type", %{user: user} do
      user_token = insert_user_token(user, typ: :refresh)

      assert {:error, changeset} = UserTokens.verify_user_token(user_token.token, :access)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end

    test "error when refresh token has a different type", %{user: user} do
      user_token = insert_user_token(user, typ: :access)

      assert {:error, changeset} = UserTokens.verify_user_token(user_token.token, :refresh)
      errors = errors_on(changeset)

      assert Enum.member?(errors.token, "is invalid")
    end
  end

  describe "create_user_token/2 returns" do
    test "ok when access token is valid", %{user: user} do
      assert {:ok, user_token} = UserTokens.create_user_token(user, :access)

      assert user_token.user == user
      assert user_token.type == :access
      assert user_token.user_id == user.id
      assert DateTime.to_date(user_token.expires_at) == Date.add(Date.utc_today(), 2)
    end

    test "ok when refresh token is valid", %{user: user} do
      assert {:ok, user_token} = UserTokens.create_user_token(user, :refresh)

      assert user_token.user == user
      assert user_token.type == :refresh
      assert user_token.user_id == user.id
      assert DateTime.to_date(user_token.expires_at) == Date.add(Date.utc_today(), 14)
    end

    test "error when user is invalid" do
      assert {:error, changeset} = UserTokens.create_user_token(%User{}, :access)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be signed")
    end

    test "error when type is invalid", %{user: user} do
      assert {:error, changeset} = UserTokens.create_user_token(user, :invalid_type)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.token, "can't be signed")
    end
  end

  describe "revoke_user_token/1" do
    test "returns ok auth token is revoked", %{user: user} do
      user_token = insert_user_token(user, typ: :access)

      assert {:ok, %UserToken{user: ^user}} = UserTokens.revoke_user_token(user_token)
    end
  end
end
