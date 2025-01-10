defmodule EllionWeb.AuthJsonTest do
  use EllionWeb.ConnCase, async: true

  import EllionCore.Auth.UsersFixtures

  alias EllionWeb.AuthJSON

  setup do
    {:ok, user: build_user()}
  end

  describe "renders" do
    test "a list of users", %{user: user} do
      assert %{data: [user_data]} = AuthJSON.index(%{users: [user]})

      assert user_data.id == user.id
      assert user_data.first_name == user.first_name
      assert user_data.last_name == user.last_name
      assert user_data.email == user.email
      assert user_data.avatar_url == user.avatar_url
      assert user_data.role == user.role
      assert user_data.is_verified == user.verified?
    end

    test "a single user", %{user: user} do
      assert %{data: user_data} = AuthJSON.show(%{user: user})

      assert user_data.id == user.id
      assert user_data.first_name == user.first_name
      assert user_data.last_name == user.last_name
      assert user_data.email == user.email
      assert user_data.avatar_url == user.avatar_url
      assert user_data.role == user.role
      assert user_data.is_verified == user.verified?
    end

    test "an auth token pair" do
      auth = %{access_token: "access_token", refresh_token: "refresh_token"}

      assert %{data: auth_data} = AuthJSON.show(%{auth: auth})

      assert auth_data.access_token == auth.access_token
      assert auth_data.refresh_token == auth.refresh_token
    end
  end
end
