defmodule PointingPartyWeb.LiveCardView do
  use Phoenix.LiveView

  alias PointingParty.Card

  def render(assigns) do
    # render("index.html", assigns)
    ~L"""
    <div class="row">
      <div class="card-container col-10">
        <%= if !@party_has_started do %>
          <div class="col-md-4 text-center">
            <button phx-click="start_party" class="btn-primary">Start the Party!</button>
          </div>
        <% else %>
          <%= card(assigns) %>
        <% end %>
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

  def handle_event("start_party", _, socket) do

    {:noreply, assign(socket, card: List.first(Card.cards()), party_has_started: true)}
  end

  def card(assigns) do
    ~L"""
    <div class="card text-left">
      <div class="card-header">
        <h2><%= @card.title %></h2>
      </div>
      <div class="card-body">
        <p class="card-text"><%= @card.description %></p>
        <div class="form-group text-left points-container">
          <div class="form-row align-items-center">
            <div class="col-2">
              <label for="story-points">Story Points</label>
              <select class="form-control story-points" id="story-points">
                <option>1</option>
                <option>2</option>
                <option>3</option>
                <option>5</option>
              </select>
            </div>
          </div>
          <a href="#" class="btn btn-primary">Vote!</a>
        </div>
      </div>
    </div>
    """
  end
end
