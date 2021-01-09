# Phoenix app without mix phx.new generator

Let's start by creating our elixir app

    mix new web

And then install `phoenix`, `plug_cowboy` and `jason` package.

```elixir
# mix.exs
defp deps do
  [
    {:phoenix, "~> 1.5.7"},
    {:plug_cowboy, "~> 2.0"},
    {:jason, "~> 1.2"}
  ]
end
``` 

Phoenix needs  you to explicitly tell what json engine to use, so lets do that in the configs.

```elixir
# configs.exs
config :phoenix, :json_library, Jason 

```


Now we need to create our endpoint, which will be started in the applications' OTP.
