defmodule EllionWeb.AuthenticationPlug do
  @moduledoc false
  import Plug.Conn

  alias EllionCore.Auth.UserTokens

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _opts) do
    case verify_auth_token(conn) do
      {:ok, %{user: user}} ->
        assign(conn, :current_user, user)

      _error ->
        send_resp(conn, :unauthorized, "") |> halt()
    end
  end

  defp verify_auth_token(conn) do
    conn
    |> get_req_header("authorization")
    |> List.first("")
    |> String.replace(~r/^Bearer\s/, "")
    |> UserTokens.verify_user_token(:access)
  end
end
