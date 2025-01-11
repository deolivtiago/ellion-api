defmodule EllionWeb.AuthControllerTest do
  alias EllionCore.Auth.Users.User
  use EllionWeb.ConnCase, async: true

  import EllionCore.Auth.UsersFixtures
  import EllionCore.Auth.UserTokensFixtures

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "signup/2 returns" do
    test "success when the user params are valid", %{conn: conn} do
      user_params = user_attrs(%{verified?: false})

      conn = post(conn, ~p"/api/auth/signup", user_params)

      assert %{"data" => user_data} = json_response(conn, :created)

      assert user_data["id"]
      assert user_data["first_name"] == user_params.first_name
      assert user_data["last_name"] == user_params.last_name
      assert user_data["email"] == user_params.email
      assert user_data["avatar_url"] == user_params.avatar_url
      assert user_data["role"] == Atom.to_string(user_params.role)
      assert user_data["is_verified"] == user_params.verified?
    end

    test "error when the user params are invalid", %{conn: conn} do
      user_params = %{email: "", first_name: nil, password: "?", role: "invalid.role"}

      conn = post(conn, ~p"/api/auth/signup", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["first_name"], "can't be blank")
      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "should be at least 6 character(s)")
      assert Enum.member?(errors["role"], "is invalid")
    end

    test "error when the user email has already been taken", %{conn: conn} do
      user_params = user_attrs(%{email: insert_user().email})

      conn = post(conn, ~p"/api/auth/signup", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has already been taken")
    end
  end

  describe "signin/2 returns" do
    setup [:put_user]

    test "success when user credentials are correct", %{conn: conn, user: user} do
      user_params = %{email: user.email, password: "P455w0rd?"}

      conn = post(conn, ~p"/api/auth/signin", user_params)

      assert %{"data" => auth_data} = json_response(conn, :ok)

      assert auth_data["access_token"]
      assert auth_data["refresh_token"]
    end

    test "error when user credentials are incorrect", %{conn: conn} do
      user_params = %{email: "invalid@mail.com", password: "invalid.password"}

      conn = post(conn, ~p"/api/auth/signin", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "is incorrect")
      assert Enum.member?(errors["password"], "is incorrect")
    end

    test "error when user credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/signin", %{})

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "can't be blank")
    end
  end

  describe "me/2 returns" do
    setup [:put_user]

    test "success when the user is authenticated", %{conn: conn, user: user} do
      token = insert_user_token(user, typ: :access) |> Map.get(:token)
      conn = put_req_header(conn, "authorization", "Bearer #{token}") |> get(~p"/api/auth/me")

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["is_verified"] == user.verified?
    end

    test "error when the user is not authenticated", %{conn: conn} do
      assert response(get(conn, ~p"/api/auth/me"), :unauthorized)
    end
  end

  describe "signout/2 returns" do
    setup [:put_user]

    test "success when deleting tokens", %{conn: conn, user: user} do
      tokens =
        Map.new()
        |> Map.put(:access_token, insert_user_token(user, typ: :access) |> Map.get(:token))
        |> Map.put(:refresh_token, insert_user_token(user, typ: :refresh) |> Map.get(:token))

      assert response(delete(conn, ~p"/api/auth/signout"), :no_content)
      assert response(delete(conn, ~p"/api/auth/signout", tokens), :no_content)
      assert response(delete(conn, ~p"/api/auth/signout", %{access_token: true}), :no_content)
    end
  end

  describe "verify/2 returns" do
    setup [:put_user]

    test "success when the email has been sent to user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/auth/verify", email: user.email)

      assert response(conn, :no_content)
    end

    test "error when the email is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/verify", email: "not.found@mail.com")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "not found")
    end

    test "error when the email is not given", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/verify")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "can't be blank")
    end

    test "error when the email is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/auth/verify", email: "???")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has invalid format")
    end
  end

  describe "confirm/2 returns" do
    test "success when verification code is valid", %{conn: conn} do
      user = insert_user(%{verified?: false})
      user_params = %{email: user.email, code: User.new_verification_code(user)}

      conn = post(conn, ~p"/api/auth/confirm", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"]
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["is_verified"] == true
    end

    test "error when verification code is invalid", %{conn: conn} do
      user = insert_user(%{verified?: false})
      user_params = %{email: user.email, code: "123456"}

      conn = post(conn, ~p"/api/auth/confirm", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["code"], "is invalid")
    end

    test "error when email is not found", %{conn: conn} do
      user_params = %{email: "not.found@mail.com", code: "123456"}

      conn = post(conn, ~p"/api/auth/confirm", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "not found")
    end

    test "error when email is invalid", %{conn: conn} do
      user_params = %{email: "???", code: "???"}

      conn = post(conn, ~p"/api/auth/confirm", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["email"], "has invalid format")
      assert Enum.member?(errors["code"], "should be 6 character(s)")
    end
  end

  describe "refresh/2 returns" do
    setup [:put_user]

    test "success when token is valid", %{conn: conn, user: user} do
      token = insert_user_token(user, typ: :refresh) |> Map.get(:token)

      conn = post(conn, ~p"/api/auth/refresh", token: token)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["access_token"]
      assert user_data["refresh_token"]
    end

    test "error when token is invalid", %{conn: conn, user: user} do
      token = insert_user_token(user, typ: :refresh) |> Map.get(:token)

      post(conn, ~p"/api/auth/refresh", token: token)
      conn = post(conn, ~p"/api/auth/refresh", token: token)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["token"], "is invalid")
    end

    test "error when token is not given", %{conn: conn} do
      conn = post(conn, ~p"/api/auth/refresh")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["token"], "can't be blank")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end
end
