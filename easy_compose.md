# Running Phoenix application in docker-compose with ease
![](https://hsto.org/webt/2-/ty/ok/2-tyokqzevcwzvb59ymi1qlbhfe.png)

We will setup a #Phoenix application inside a #Docker container and run it on development environment.


## Creating the application
Starting from scratch, let's create our Phoenix application

```
mix phx.new easy_compose
```

When asked to install dependencies, say no (`n`).  
Since we are going to run the application inside a container we won't need its dependencies on our machine. :wink:  

## The Dockerfile - building the application image
Now let's build the `Dockerfile`. We are going to use the `elixir:1.10.4-alpine` image.  
In a container we will need:  

Some system dependencies:
```
apk add --no-cache build-base npm git python inotify-tools
```
[Hex](https://hex.pm/) and [Rebar](https://www.rebar3.org/):
```
mix do local.hex, local.rebar
```

Install our dependencies listed on `mix.exs`:
```
mix do deps.get, deps.compile
```

Compile our app, that lives in `lib/`
```
mix compile
```

And install node dependencies
```
npm install --prefix ./assets
```

After running all these commands we are able to `mix phx.server` inside a docker container. Let's put it all in a Dockerfile and try.  
`cd` into your `easy_compose/` folder and create the `Dockerfile`

```Dockerfile

FROM elixir:1.10.4-alpine

# install build dependencies
RUN apk add --no-cache build-base npm git python inotify-tools

# prepare build dir
WORKDIR /app

# install hex and rebar
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# compile app
COPY lib lib
RUN mix compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix ./assets --progress=false --no-audit --loglevel=error

# run server
CMD ["mix", "phx.server"]
```

This is our first time running this application so we better run `mix deps.get` in order to generate the `mix.lock` file, which was included in the `Dockerfile`.
The same for npm, we gotta run `npm install --package-lock-only --prefix ./assets` to get the node file `package-lock.json`. And we are ready to build our docker image.

```
docker build --tag easy_compose .
```

Now if you run `docker image ls` you should see our new image.
```
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
easy_compose        latest              b19489228953        About a minute ago   449MB
```

If we try to just start a container from this image: `docker run --rm easy_compose` we should see an error because we still have no database configured. We will
configure it inside the docker-compose. Let's start with it.

## Creating the docker-compose
The first structure we can think of is as follows:  
Create a file called `docker-compose.yml` containing these lines.

```yml
version: '3.7'

services:
  web:
    build: .
    volumes:
      - .:/app
    ports:
      - 4000:4000
    depends_on:
      - db
  db:
    image: postgres:12
    volumes:
      - postgres_data:/var/lib/postgresql/data/
volumes:
  postgres_data:
```
And try to run the containers: `docker-compose up`  
Sadly this won't work. :worried: , `CRTL + C` to stop the containers and run `docker-compose down` to remove the stopped containers.

First, the database container was started with no user password. Since we are in development environment we shouldn't care about database passwords, so we pass
the following environment variable: `POSTGRES_HOST_AUTH_METHOD=trust` in order to allow container start without a password.  

Second problem was our application was trying to compile again, it seems like it could't find the `_build/` and `deps/` folder and that's because after we
built our image, docker-compose is mounting our machine folder `easy_compose/` entirely to the container working directory `app/`, but this ends up erasing all
artifacts generated at building stage. To prevent this behaviour we gotta add more volumes to the `web` service. This way our container
can access his `_build/` and `deps/` inside our machine `/var/lib/docker/volumes/` rather than the `easy_compose/` folder.  
After all the changes we should get the following `docker-compose.yml`

```yml
version: '3.7'

services:
  web:
    build: .
    volumes:
      - .:/app
      - /app/_build
      - /app/deps
      - /app/priv/static
      - /app/assets/node_modules
    ports:
      - 4000:4000
    depends_on:
      - db
  db:
    image: postgres:12
    environment:
      - POSTGRES_HOST_AUTH_METHOD=trust
    volumes:
      - postgres_data:/var/lib/postgresql/data/
volumes:
  postgres_data:
```

If we try to run again we will see that the database is started but we still got an error
```
web_1  | [error] Postgrex.Protocol (#PID<0.367.0>) failed to connect: ** (DBConnection.ConnectionError) tcp connect (localhost:5432): connection refused - :econnrefused

```
It's because we han't configured our application to fetch our database. We can do this by going to `config/dev.exs` and changing the `hostname` from 
`localhost` to our service name, which is `db`.  

```elixir
# Configure your database
config :easy_compose, EasyCompose.Repo,
  username: "postgres",
  password: "postgres",
  database: "easy_compose_dev",
  hostname: "db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

```

Stop docker-compose, `CRTL + C`, make the changes (in `config/dev.exs`) and start it again, `docker-compose up`.  
Now we got another error:
```
db_1   | 2020-08-27 12:36:11.978 UTC [43] FATAL:  database "easy_compose_dev" does not exist
web_1  | [error] Postgrex.Protocol (#PID<0.449.0>) failed to connect: ** (Postgrex.Error) FATAL 3D000 (invalid_catalog_name) database "easy_compose_dev" does not exist
```

But this is just because we didn't created the database. Stop the container once again and now run

```
docker-compose run web mix ecto.create
```

And start docker-compose again
```
docker-compose up
```

No errors this time! :tada::tada::tada:  
Go to http://127.0.0.1:4000 and you have a working phoenix application on docker-compose. :sunglasses:

![](https://i.imgur.com/20LVnuP.png)




