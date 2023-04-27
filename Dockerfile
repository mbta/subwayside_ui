ARG ELIXIR_VERSION=1.14.4
ARG ERLANG_VERSION=25.3
#ARG NODE_VERSION=18.16.0
ARG ALPINE_VERSION=3.17.2

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${ERLANG_VERSION}-alpine-${ALPINE_VERSION} as builder

WORKDIR /root

# Install Hex+Rebar
RUN mix local.hex --force && \
  mix local.rebar --force

RUN apk add --update git

ENV MIX_ENV=prod

ADD config/config.exs config/prod.exs config/
ADD mix.exs mix.lock ./

RUN mix do deps.get --only prod, deps.compile, assets.setup

ADD assets assets
ADD config/runtime.exs config/
ADD lib lib
ADD priv priv

RUN mix do assets.deploy, compile, release

# The one the elixir image was built with
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache libssl1.1 dumb-init libstdc++ libgcc ncurses-libs && \
    mkdir /work /subwayside_ui && \
    adduser -D subwayside_ui && chown subwayside_ui /work

COPY --from=builder /root/_build/prod/rel/subwayside_ui /subwayside_ui

# Set exposed ports
EXPOSE 4000
ENV PORT=4000 MIX_ENV=prod TERM=xterm LANG=C.UTF-8 \
    ERL_CRASH_DUMP_SECONDS=0 RELEASE_TMP=/work

USER subwayside_ui
WORKDIR /work

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

HEALTHCHECK CMD ["/subwayside_ui/bin/subwayside_ui", "rpc", "1 + 1"]
CMD ["/subwayside_ui/bin/subwayside_ui", "start"]
