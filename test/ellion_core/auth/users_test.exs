defmodule EllionCore.Auth.UsersTest do
  use EllionCore.DataCase, async: true

  import EllionCore.Auth.UsersFixtures

  alias Ecto.Changeset

  alias EllionCore.Auth.Users
  alias EllionCore.Auth.Users.User

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "list_users/0" do
    test "without users returns an empty list" do
      assert [] == Users.list_users()
    end

    test "with users returns all users" do
      user = insert_user()

      assert [user] == Users.list_users()
    end
  end

  describe "get_user/3 returns" do
    setup [:put_user]

    test "ok when the given id is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:id, user.id)
    end

    test "error when the given id is not found" do
      id = Ecto.UUID.generate()

      assert {:error, changeset} = Users.get_user(:id, id)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end

    test "ok when the given email is found", %{user: user} do
      assert {:ok, user} == Users.get_user(:email, user.email)
    end

    test "error when the given email is not found" do
      assert {:error, changeset} = Users.get_user(:email, "not.found@mail.com")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "not found")
    end

    test "ok when the given email is verified", %{user: user} do
      assert {:ok, user} == Users.get_user(:email, user.email, verified?: true)
    end

    test "error when the given email is not verified" do
      user = insert_user(%{verified?: false})

      assert {:error, changeset} = Users.get_user(:email, user.email, verified?: true)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "must be verified")
    end
  end

  describe "create_user/1 returns" do
    test "ok when the user attributes are valid", %{attrs: attrs} do
      assert {:ok, %User{} = user} = Users.create_user(attrs)

      assert user.first_name == attrs.first_name
      assert user.last_name == attrs.last_name
      assert user.email == attrs.email
      assert user.role == attrs.role
      assert Argon2.verify_pass(attrs.password, user.password)
    end

    test "error when the user attributes are invalid" do
      attrs = %{email: "???", first_name: nil, password: "?", role: "invalid"}

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
      assert Enum.member?(errors.role, "is invalid")
    end

    test "error when the user email already exists", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, insert_user().email)

      assert {:error, changeset} = Users.create_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has already been taken")
    end
  end

  describe "update_user/2 returns" do
    setup [:put_user]

    test "ok when the user attributes are valid", %{user: %{id: id} = user, attrs: attrs} do
      assert {:ok, %User{id: ^id} = user} = Users.update_user(user, attrs)

      assert attrs.id != user.id
      assert attrs.first_name == user.first_name
      assert attrs.last_name == user.last_name
      assert attrs.role == user.role
      assert Argon2.verify_pass(attrs.password, user.password)
    end

    test "error when the user attributes are invalid", %{user: user} do
      invalid_attrs = %{email: "?@?", first_name: "", password: "?", role: 0}

      assert {:error, changeset} = Users.update_user(user, invalid_attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
      assert Enum.member?(errors.email, "has invalid format")
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
      assert Enum.member?(errors.role, "is invalid")
    end
  end

  describe "delete_user/1 returns" do
    setup [:put_user]

    test "ok when the user is deleted", %{user: user} do
      assert {:ok, %User{}} = Users.delete_user(user)

      assert {:error, changeset} = Users.delete_user(user)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.id, "not found")
    end
  end

  describe "authenticate/2 returns" do
    test "ok when the given password is valid", %{attrs: attrs} do
      user = insert_user(attrs)

      assert {:ok, user} == Users.authenticate_user(attrs)
    end

    test "error when the given email is invalid", %{attrs: attrs} do
      insert_user(attrs)
      attrs = %{email: "another@mail.com", password: attrs.password}

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "is incorrect")
      assert Enum.member?(errors.password, "is incorrect")
    end

    test "error when the given email is not verified", %{attrs: attrs} do
      insert_user(%{attrs | verified?: false})

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "must be verified")
    end

    test "error when the given password is invalid", %{attrs: attrs} do
      attrs = %{email: insert_user(attrs).email, password: "invalid.password"}

      assert {:error, changeset} = Users.authenticate_user(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "is incorrect")
      assert Enum.member?(errors.password, "is incorrect")
    end
  end

  describe "verify_user/2 returns ok" do
    setup [:put_user]

    test "when the verification email has been sent", %{user: user} do
      assert {:ok, %Swoosh.Email{}} = Users.verify_user(user, :confirm_account)
      assert {:ok, %Swoosh.Email{}} = Users.verify_user(user, :reset_password)
      assert {:ok, %Swoosh.Email{}} = Users.verify_user(user, :update_email)
    end
  end

  describe "confirm_user/2 returns" do
    test "ok when the given code is valid" do
      user = insert_user(%{verified?: false})
      code = User.new_verification_code(user)

      assert {:ok, %{user | verified?: true}} == Users.confirm_user(user, code)
    end

    test "error when the given code is invalid" do
      user = insert_user()

      assert {:error, changeset} = Users.confirm_user(user, "666666")
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.code, "is invalid")
    end
  end

  defp put_user(_) do
    {:ok, user: insert_user()}
  end
end
