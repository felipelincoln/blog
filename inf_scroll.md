# Infinite scroll using Phoenix LiveView

![](https://brendysbookreport.com/wp-content/uploads/2018/05/Screen-Shot-2018-05-08-at-3.48.10-PM.png)

## Boilerplate
Start a phoenix application:
```
mix phx.new inf_scroll --live --no-ecto
```

I created a list of digimons from Digimon World 1 so we can test our infinity scroll feed.
```elixir
defmodule InfScroll.Digimons do
  def list_digimons do
    [
      %{
        category: :baby,
        name: "botamon"
      },
      %{
        category: :baby,
        name: "punimon"
      },
      %{
        category: :baby,
        name: "poyomon"
      },
      ...
  end
end
```
Just drop [this file](inf_scroll/lib/inf_scroll/digimons.ex) in your `inf_scroll/lib/inf_scroll/` folder and we can hit the ground running.

## Creating our page
Lets define our first live page. Go to `inf_scroll/lib/inf_scroll_web/router.ex` and add below `live "/", PageLive, :index` the following line:
```elixir
live "/scroll", ScrollLive
```

We have setup the `/scroll` route and now we need to implement its presentation. Create the file `scroll_live.ex` in `inf_scroll/lib/inf_scroll_web/live`
containing only the minimal structure.

```elixir
defmodule InfScrollWeb.ScrollLive do
  use InfScrollWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    it's working!
    """
  end
end

```

If we now fire up the server
```
mix phx.server
```

and go to `127.0.0.1:4000/scroll`, it should looks like this:
![](https://i.imgur.com/zOs30oK.png)

## Creating a feed
At first we are going to make the feed show every item on our list.  
Lets alias `InfScroll.Digimons` and assign the digimon list to the socket on `scroll_live.ex`'s `mount`.

```elixir
defmodule InfScrollWeb.ScrollLive do
  use InfScrollWeb, :live_view

  alias InfScroll.Digimons

  def mount(_params, _session, socket) do
    feed = Digimons.list_digimons()
    socket = assign(socket, feed: feed)

    {:ok, socket}
  end
```

We can show this list using the following `render` (I added some fancy inline styles :smile:):

```elixir
def render(assigns) do
  ~L"""
  <div>
  <%= for i <- @feed do %>
    <div style="padding:15px; border:1px solid lightgrey; border-radius: 15px; width: 250px; margin: 10px auto">
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
```
What we have now is the following:
![](https://i.imgur.com/vXhLekJ.gif)

## Paginating the feed
We can easily paginate the `Digimons.list_digimons()` defining the following `/2` arity clause for this function

```elixir
def list_digimons(page, per_page \\ 10) do
  list_digimons()
  |> Enum.chunk_every(per_page)
  |> List.pop_at(page)
  |> (fn {item, _new_list} -> item end).()
end
```

Lets run `iex lib/inf_scroll/digimons.ex` to take a look at what is happening under the hood:

```elixir
iex(1)> InfScroll.Digimons.list_digimons() |> Enum.chunk_every(5) 
[
  [
    %{category: :baby, name: "botamon"},
    %{category: :baby, name: "punimon"},
    %{category: :baby, name: "poyomon"},
    %{category: :baby, name: "yuramon"},
    %{category: :trainee, name: "koromon"}
  ],
  [
    %{category: :trainee, name: "tsunomon"},
    %{category: :trainee, name: "tokomon"},
    %{category: :trainee, name: "tanemon"},
    %{category: :rookie, name: "agumon"},
    %{category: :rookie, name: "betamon"}
  ],
  [
    %{category: :rookie, name: "elecmon"},
    %{category: :rookie, name: "gabumon"},
    %{category: :rookie, name: "kunemon"},
    %{category: :rookie, name: "palmon"},
    %{category: :rookie, name: "patamon"}
  ],
  ...
]
iex(2)> InfScroll.Digimons.list_digimons() |> Enum.chunk_every(5) |> List.pop_at(2)
{[
   %{category: :rookie, name: "elecmon"},
   %{category: :rookie, name: "gabumon"},
   %{category: :rookie, name: "kunemon"},
   %{category: :rookie, name: "palmon"},
   %{category: :rookie, name: "patamon"}
 ],
 [
   [
     %{category: :baby, name: "botamon"},
     %{category: :baby, name: "punimon"},
     %{category: :baby, name: "poyomon"},
     %{category: :baby, name: "yuramon"},
     %{category: :trainee, name: "koromon"}
   ],
   [
     %{category: :trainee, name: "tsunomon"},
     %{category: :trainee, name: "tokomon"},
     %{category: :trainee, name: "tanemon"},
     %{category: :rookie, name: "agumon"},
     %{category: :rookie, name: "betamon"}
   ],
   ...
 ]}
iex(3)> InfScroll.Digimons.list_digimons() |> Enum.chunk_every(5) |> List.pop_at(2) |> (fn {item, _new_list} -> item end).()
[
  %{category: :rookie, name: "elecmon"},
  %{category: :rookie, name: "gabumon"},
  %{category: :rookie, name: "kunemon"},
  %{category: :rookie, name: "palmon"},
  %{category: :rookie, name: "patamon"}
]

```

Divide our list into chunks of length 5, then pop the 2-index item from this list. `List.pop_at/2` returns a tuple `{poped_item, new_list}`, that's why we needed that annonymous function at the end. Got it? :wink:  
Now that we have our paginate logic implemented, lets create a button to load more content.

We need to store the state of our feed, we do this by assigning `page` to `mount`'s socket. We also want to use the `feed` assign to hold the new
content that will be added to the feed, so we need to put `temporary_assigns: [feed: []]` to our returning tuple, this will restore to `[]` after the feed content
is rendered.

```elixir
def mount(_params, _session, socket) do
  feed = Digimons.list_digimons(0)
  socket = assign(socket, feed: feed, page: 0)

  {:ok, socket, temporary_assigns: [feed: []]}
end
```

We also havo to set the phoenix binding `phx-update="append"` (default is `replace`) to our container div in the `render` template. This will append our
new items to the end of the feed rather than replacing it all. In order to use this feature we also have to provide an unique DOM ID to the container div and to
each item on our feed.

```elixir
def render(assigns) do
  ~L"""
  <div id="feed" phx-update="append">
  <%= for i <- @feed do %>
    <div id="<%= i.name %>"
         style="padding:15px; border:1px solid lightgrey; border-radius: 15px; width: 250px; margin: 10px auto">
  ...
  """
end
```

Finally we can add the button:

```elixir
  def render(assigns) do
    ~L"""
    ...
    <button phx-click="load-more">Load more</button>
    """
  end

  def handle_event("load-more", _params, %{assigns: %{page: page}} = socket) do
    new_page = page + 1
    new_feed = Digimons.list_digimons(new_page)
    socket = assign(socket, feed: new_feed, page: new_page)

    {:noreply, socket}
  end

```

We have already a paginated feed! We are almost there.

![](https://i.imgur.com/H0TjCnh.gif)

## JS Hooks, the end!!
Now we will get rid of the button and load content as we scroll.  

Lets first define a JavaScript function that get our current scroll position.

```javascript
let scrollAt = () => {
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  let clientHeight = document.documentElement.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}
```

Press `F12` in your phoenix project browser tab and paste the code above in the console, and see what it does.

![](https://i.imgur.com/kK2RQL2.gif)

We will refer to this function soon.  
The last thing we need to do is setup a [javascript hook](https://hexdocs.pm/phoenix_live_view/js-interop.html). The key here is to add an event listener to
`window` to listen to the `scroll` event, when the `scrollAt()` returns a value greater than 90, we are going to fire an event to the server using `pushEvent("load-more", {})`. All this functionality will be passed to the `LiveSocket` instance via `hooks`.  

The following snippet will do the trick, put this after the imports in your `assets/js/app.js`

```javascript
let scrollAt = () => {
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  let clientHeight = document.documentElement.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}

let Hooks = {}
Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted(){
    this.pending = this.page()
    window.addEventListener("scroll", e => {
      if(this.pending == this.page() && scrollAt() > 90){
        this.pending = this.page() + 1
        this.pushEvent("load-more", {})
      }
    })
  },
  reconnected(){ this.pending = this.page() },
  updated(){ this.pending = this.page() }
}
```

Now make sure to include this Hooks object into the socket, that is right below `csrf_token`.

```javascript
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})
```

In the render template at `lib/inf_scroll_web/live/scroll_live.ex`, we need to include `phx-hook="InfiniteScroll" data-page="<%= @page %>"` to the container div and we can get rid of the "load more" button.

```elixir
  def render(assigns) do
    ~L"""
    <div id="feed" phx-update="append" phx-hook="InfiniteScroll" data-page="<%= @page %>">
    ...
    </div>
    """
  end

```

## That's it!
![](https://i.imgur.com/SGgxHbs.gif)

\*I did not handle the case where we reach the end of the feed, I am waiting for your pull request :wink:

