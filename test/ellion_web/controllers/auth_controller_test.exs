defmodule EllionWeb.AuthControllerTest do
  use EllionWeb.ConnCase, async: true

  import EllionCore.Auth.UsersFixtures
  import EllionCore.Auth.UserTokensFixtures

  @id_not_found Ecto.UUID.generate()

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

  describe "update/2 returns" do
    setup [:put_user]

    test "success when the user params are valid", %{conn: conn, user: user} do
      user_params = user_attrs()

      conn = put(conn, ~p"/api/users/#{user}", user_params)

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["first_name"] == user_params.first_name
      assert user_data["last_name"] == user_params.last_name
      assert user_data["email"] == user_params.email
      assert user_data["avatar_url"] == user_params.avatar_url
      assert user_data["role"] == Atom.to_string(user_params.role)
      assert user_data["is_verified"] == user_params.verified?
    end

    test "error when the user params are invalid", %{conn: conn, user: user} do
      user_params = %{email: "@@@", first_name: "", role: "invalid.role"}

      conn = put(conn, ~p"/api/users/#{user}", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["first_name"], "can't be blank")
      assert Enum.member?(errors["email"], "has invalid format")
      assert Enum.member?(errors["role"], "is invalid")
    end
  end

  describe "delete/2 returns" do
    setup [:put_user]

    test "success when the user is found", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/api/users/#{user}")

      assert response(conn, :no_content)
    end

    test "error when the user is not found", %{conn: conn} do
      conn = delete(conn, ~p"/api/users/#{@id_not_found}")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["id"], "not found")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end
end
