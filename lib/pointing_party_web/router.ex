defmodule PointingPartyWeb.Router do
  use PointingPartyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PointingPartyWeb do
    pipe_through :browser
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete
    get "/", PageController, :index
  end

  scope "/", PointingPartyWeb do
    pipe_through [:browser, PointingPartyWeb.Plugs.Auth]
    get "/cards", CardController, :index
  end
end
