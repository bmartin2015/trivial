defmodule TrivialWeb.Router do
  use TrivialWeb, :router

  import TrivialWeb.AuthHelper

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TrivialWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :google_auth do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TrivialWeb.LayoutView, :root}
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrivialWeb do
    pipe_through :browser

    live "/", PageLive, :index
    delete "/users/log_out", UserSessionController, :delete
  end

  scope "/users", TrivialWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/log_in", UserSessionController, :new
  end

  scope "/auth", TrivialWeb do
    pipe_through :google_auth

    post "/:provider/callback", UserSessionController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", TrivialWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TrivialWeb.Telemetry
    end
  end
end
