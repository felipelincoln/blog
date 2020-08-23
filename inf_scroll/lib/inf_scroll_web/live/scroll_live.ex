defmodule InfScrollWeb.ScrollLive do
  use InfScrollWeb, :live_view

  alias InfScroll.Digimons

  def mount(_params, _session, socket) do
    feed = Digimons.list_digimons(0)
    socket = assign(socket, feed: feed, page: 0)

    {:ok, socket, temporary_assigns: [feed: []]}
  end

  def render(assigns) do
    ~L"""
    <div id="feed" phx-update="append" phx-hook="InfiniteScroll" data-page="<%= @page %>">
    <%= for i <- @feed do %>
      <div id="<%= i.name %>"
           style="padding:15px; border:1px solid lightgrey; border-radius: 15px; width: 250px; margin: 10px auto">
        <p style="text-transform: capitalize">
          <span style="font-weight: bold"><%= i.name %></span>
          <small style="float:right;padding:5px;border-radius:5px;background-color:<%= get_color(i.category) %>">
          <%= i.category %></small>
        </p>
        <img src="https://digimon.shadowsmith.com/img/<%= i.name %>.jpg"
             onerror="this.src='https://748073e22e8db794416a-cc51ef6b37841580002827d4d94d19b6.ssl.cf3.rackcdn.com/not-found.png'">
      </div>
    <% end %>
    </div>
    """
  end

  def handle_event("load-more", _params, %{assigns: %{page: page}} = socket) do
    new_page = page + 1
    new_feed = Digimons.list_digimons(new_page)
    socket = assign(socket, feed: new_feed, page: new_page)

    {:noreply, socket}
  end

  defp get_color(category) do
    case category do
      :baby ->
        "antiquewhite"
      :trainee ->
        "aquamarine"
      :rookie ->
        "lightblue"
      :champion ->
        "coral"
      :ultimate ->
        "pink"
    end
  end
end
