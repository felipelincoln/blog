# Running Phoenix application in docker-compose with ease
![](https://hsto.org/webt/2-/ty/ok/2-tyokqzevcwzvb59ymi1qlbhfe.png)

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
The first structure we can think of is as follows

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

but sadly this won't work. :worried:  
First, the database container was started with no user password. Since we are in development environment we shouldn't care about database passwords, so we pass
the following environment variable: `POSTGRES_HOST_AUTH_METHOD=trust` in order to allow container start without a password.  
Second problem was our application was trying to compile again, it seems like it could't find the `_build/` and `deps/` folder












