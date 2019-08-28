defmodule PointingPartyWeb.CardController do
  use PointingPartyWeb, :controller

  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    %{assigns: %{username: username}} = conn
    # render the LiveView here
  end
end
