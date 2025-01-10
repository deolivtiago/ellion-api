defmodule EllionWeb.AuthController do
  @moduledoc false
  use EllionWeb, :controller

  alias EllionWeb.AuthController.Confirm
  alias EllionWeb.AuthController.Refresh
  alias EllionWeb.AuthController.SignIn
  alias EllionWeb.AuthController.SignOut
  alias EllionWeb.AuthController.SignUp
  alias EllionWeb.AuthController.Verify

  action_fallback EllionWeb.FallbackController

  @doc false
  def signup(conn, params) do
    with {:ok, user} <- SignUp.handle(params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end

  @doc false
  def signin(conn, params) do
    with {:ok, auth} <- SignIn.handle(params) do
      conn
      |> put_status(:ok)
      |> render(:show, auth: auth)
    end
  end

  @doc false
  def signout(conn, params) do
    SignOut.handle(params)

    send_resp(conn, :no_content, "")
  end

  @doc false
  def verify(conn, params) do
    with {:ok, _user} <- Verify.handle(params) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc false
  def confirm(conn, params) do
    with {:ok, user} <- Confirm.handle(params) do
      render(conn, :show, user: user)
    end
  end

  @doc false
  def refresh(conn, params) do
    with {:ok, auth} <- Refresh.handle(params) do
      render(conn, :show, auth: auth)
    end
  end

  @doc false
  def me(%{assigns: %{current_user: user}} = conn, _params) do
    render(conn, :show, user: user)
  end
end
