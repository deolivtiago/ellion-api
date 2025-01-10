defmodule EllionWeb.Router do
  use EllionWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug EllionWeb.AuthenticationPlug
  end

  scope "/api", EllionWeb do
    pipe_through :api

    post "/auth/signup", AuthController, :signup
    post "/auth/signin", AuthController, :signin
    get "/auth/verify", AuthController, :verify
    post "/auth/confirm", AuthController, :confirm
    post "/auth/refresh", AuthController, :refresh
    delete "/auth/signout", AuthController, :signout
  end

  scope "/api", EllionWeb do
    pipe_through [:api, :auth]

    get "/auth/me", AuthController, :me
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:ellion, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
