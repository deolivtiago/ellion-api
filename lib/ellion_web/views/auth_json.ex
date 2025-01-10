defmodule EllionWeb.AuthJSON do
  @moduledoc false

  alias EllionCore.Auth.Users.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}), do: %{data: for(user <- users, do: data(user))}

  @doc """
  Renders a single user or its auth tokens.
  """
  def show(%{user: user}), do: %{data: data(user)}

  def show(%{auth: auth}), do: %{data: auth}

  defp data(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      avatar_url: user.avatar_url,
      role: user.role,
      is_verified: user.verified?
    }
  end
end
