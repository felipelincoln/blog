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
Lets alias `InfScroll.Digimons` and assigns the list to the socket, your `scroll_live.ex`
should look like this at this point:

```elixir

```














