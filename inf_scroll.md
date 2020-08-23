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






