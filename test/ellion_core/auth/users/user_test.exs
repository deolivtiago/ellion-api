defmodule EllionCore.Auth.Users.UserTest do
  use EllionCore.DataCase, async: true

  import EllionCore.Auth.UsersFixtures

  alias Ecto.Changeset
  alias EllionCore.Auth.Users.User

  setup do
    {:ok, attrs: user_attrs()}
  end

  describe "changeset/1 returns a valid changeset" do
    test "when first name is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :first_name) == attrs.first_name
    end

    test "when last name is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :last_name) == attrs.last_name
    end

    test "when email is valid", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role) == attrs.role

      attrs = Map.delete(attrs, :role)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when avatar url is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when verified? is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :verified?) == attrs.verified?

      attrs = Map.delete(attrs, :verified?)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end

    test "when totp secret is valid", %{attrs: attrs} do
      changeset = User.changeset(attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :totp_secret) == attrs.totp_secret

      attrs = Map.delete(attrs, :totp_secret)
      assert %Changeset{valid?: true} = User.changeset(attrs)
    end
  end

  describe "changeset/1 returns an invalid changeset" do
    test "when first name is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "should be at least 2 character(s)")
    end

    test "when first name is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :first_name, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when email has invalid format", %{attrs: attrs} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when password is empty", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password is too short", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
    end

    test "when password doesn't have number(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "Password?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have number(s)")
    end

    test "when password doesn't have lower case character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "P455W0RD?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have lower case character(s)")
    end

    test "when password doesn't have upper case character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "p455w0rd?")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have upper case character(s)")
    end

    test "when password doesn't have special character(s)", %{attrs: attrs} do
      attrs = Map.put(attrs, :password, "P455w0rd")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have symbol(s)")
    end

    test "when verified? is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :verified?, "invalid.value")

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.verified?, "is invalid")
    end

    test "when totp secret is invalid", %{attrs: attrs} do
      attrs = Map.put(attrs, :totp_secret, 1)

      changeset = User.changeset(attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.totp_secret, "is invalid")
    end
  end

  describe "changeset/2 returns a valid changeset" do
    setup [:put_user]

    test "when avatar url is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :avatar_url) == attrs.avatar_url

      attrs = Map.delete(attrs, :avatar_url)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when first name is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :first_name) == attrs.first_name
    end

    test "when email is valid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, String.upcase(attrs.email))

      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :email) == String.downcase(attrs.email)
    end

    test "when password is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true, changes: changes} = changeset
      assert Argon2.verify_pass(attrs.password, changes.password)
    end

    test "when role is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :role) == attrs.role

      attrs = Map.delete(attrs, :role)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when verified? is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :verified?) == attrs.verified?

      attrs = Map.delete(attrs, :verified?)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end

    test "when totp secret is valid", %{attrs: attrs, user: user} do
      changeset = User.changeset(user, attrs)

      assert %Changeset{valid?: true} = changeset
      assert Changeset.get_field(changeset, :totp_secret) == attrs.totp_secret

      attrs = Map.delete(attrs, :totp_secret)
      assert %Changeset{valid?: true} = User.changeset(user, attrs)
    end
  end

  describe "changeset/2 returns an invalid changeset" do
    setup [:put_user]

    test "when first name is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :first_name, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "should be at least 2 character(s)")
    end

    test "when first name is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :first_name, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.first_name, "can't be blank")
    end

    test "when email is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "can't be blank")
    end

    test "when email has invalid format", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "email.invalid")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "has invalid format")
    end

    test "when email is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :email, "@@")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.email, "should be at least 3 character(s)")
    end

    test "when password is too short", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "should be at least 6 character(s)")
    end

    test "when password is empty", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "can't be blank")
    end

    test "when password doesn't have number(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "Password?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have number(s)")
    end

    test "when password doesn't have lower case character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "P455W0RD?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have lower case character(s)")
    end

    test "when password doesn't have upper case character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "p455w0rd?")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have upper case character(s)")
    end

    test "when password doesn't have special character(s)", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :password, "p455w0rd")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.password, "must have symbol(s)")
    end

    test "when verified? is invalid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :verified?, "invalid.value")

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.verified?, "is invalid")
    end

    test "when totp secret is invalid", %{attrs: attrs, user: user} do
      attrs = Map.put(attrs, :totp_secret, 1)

      changeset = User.changeset(user, attrs)
      errors = errors_on(changeset)

      assert %Changeset{valid?: false} = changeset
      assert Enum.member?(errors.totp_secret, "is invalid")
    end
  end

  describe "new_verification_code/1 and valid_verification_code/2" do
    setup [:put_user]

    test "generate and validate verification codes", %{user: user} do
      assert code = User.new_verification_code(user)
      assert User.valid_verification_code?(user, code)
      refute User.valid_verification_code?(user, "invalid.code")
    end
  end

  defp put_user(_context) do
    {:ok, user: build_user()}
  end
end
