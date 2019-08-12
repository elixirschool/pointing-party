defmodule PointingPartyWeb.LiveCardView do
  use Phoenix.LiveView

  def render(assigns) do
    # render("index.html", assigns)
    ~L"""
    <div class="row">
      <div class="card-container col-10">
        <div class="col-md-4 text-center">
          <%= if !@party_has_started do %>
            <button class="start-button btn btn-primary">Start the Party!</button>
          <% end %>
        </div>
      </div>

      <div class="col-2">
        <h2>Users</h2>
        <dl class="row users">
        </dl>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, party_has_started: false)}
  end
end
