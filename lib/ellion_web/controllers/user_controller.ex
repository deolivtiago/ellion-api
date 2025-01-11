defmodule EllionWeb.UserController do
  @moduledoc false
  use EllionWeb, :controller

  alias EllionWeb.UserController.Create
  alias EllionWeb.UserController.Delete
  alias EllionWeb.UserController.Index
  alias EllionWeb.UserController.Show
  alias EllionWeb.UserController.Update

  action_fallback EllionWeb.FallbackController

  @doc false
  def index(conn, params) do
    users = Index.handle(params)

    render(conn, :index, users: users)
  end

  @doc false
  def create(conn, params) do
    with {:ok, user} <- Create.handle(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user}")
      |> render(:show, user: user)
    end
  end

  @doc false
  def show(conn, params) do
    with {:ok, user} <- Show.handle(params) do
      render(conn, :show, user: user)
    end
  end

  @doc false
  def update(conn, params) do
    with {:ok, user} <- Update.handle(params) do
      render(conn, :show, user: user)
    end
  end

  @doc false
  def delete(conn, params) do
    with {:ok, _user} <- Delete.handle(params) do
      send_resp(conn, :no_content, "")
    end
  end
end
