defmodule EllionWeb.UserControllerTest do
  use EllionWeb.ConnCase, async: true

  import EllionCore.Auth.UsersFixtures

  @id_not_found Ecto.UUID.generate()

  setup %{conn: conn} do
    conn
    |> put_req_header("accept", "application/json")
    |> then(&{:ok, conn: &1})
  end

  describe "index/2 returns success" do
    setup [:put_user]

    test "with a list of users when there are users", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users")

      assert %{"data" => [user_data]} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["is_verified"] == user.verified?
    end
  end

  describe "create/2 returns" do
    setup [:put_user]

    test "success when the user params are valid", %{conn: conn} do
      user_params = user_attrs(%{verified?: false})

      conn = post(conn, ~p"/api/users", user_params)

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

      conn = post(conn, ~p"/api/users", user_params)

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["first_name"], "can't be blank")
      assert Enum.member?(errors["email"], "can't be blank")
      assert Enum.member?(errors["password"], "should be at least 6 character(s)")
      assert Enum.member?(errors["role"], "is invalid")
    end
  end

  describe "show/2 returns" do
    setup [:put_user]

    test "success when the user id is found", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/users/#{user}")

      assert %{"data" => user_data} = json_response(conn, :ok)

      assert user_data["id"] == user.id
      assert user_data["first_name"] == user.first_name
      assert user_data["last_name"] == user.last_name
      assert user_data["email"] == user.email
      assert user_data["avatar_url"] == user.avatar_url
      assert user_data["role"] == Atom.to_string(user.role)
      assert user_data["is_verified"] == user.verified?
    end

    test "error when the user id is not found", %{conn: conn} do
      conn = get(conn, ~p"/api/users/#{@id_not_found}")

      assert %{"errors" => errors} = json_response(conn, :unprocessable_entity)

      assert Enum.member?(errors["id"], "not found")
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
