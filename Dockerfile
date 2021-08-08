FROM bitwalker/alpine-elixir-phoenix:1.11.4

RUN apk --no-cache --update add alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3 file

# Get Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="$HOME/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-feature=-crt-static"

EXPOSE 4000

ENV PORT=4000 \
    MIX_ENV="prod" \
    SECRET_KEY_BASE="RMgI4C1HSkxsEjdhtGMfwAHfyT6CKWXOgzCboJflfSm4jeAlic52io05KB6mqzc5"

# Cache elixir deps
ADD mix.exs mix.lock ./
ADD apps/block_scout_web/mix.exs ./apps/block_scout_web/
ADD apps/explorer/mix.exs ./apps/explorer/
ADD apps/ethereum_jsonrpc/mix.exs ./apps/ethereum_jsonrpc/
ADD apps/indexer/mix.exs ./apps/indexer/

RUN mix do deps.get, local.rebar --force, deps.compile

ARG COIN
RUN if [ "$COIN" != "" ]; then\
    lineNum="$(grep -n 'msgid \"Ether\"' apps/block_scout_web/priv/gettext/default.pot | head -n 1 | cut -d: -f1)";\
    lineToChange=`expr $lineNum + 1`;\
    sed -i "${lineToChange}s/msgstr \"\"/msgstr \"${COIN}\"/" apps/block_scout_web/priv/gettext/default.pot;\
    lineNum="$(grep -n 'msgid \"Ether\"' apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po | head -n 1 | cut -d: -f1)";\
    lineToChange=`expr $lineNum + 1`;\
    sed -i "${lineToChange}s/msgstr \"\"/msgstr \"${COIN}\"/" apps/block_scout_web/priv/gettext/en/LC_MESSAGES/default.po;\
    fi

# Run forderground build and phoenix digest
RUN mix compile

# Add blockscout npm deps
RUN cd apps/block_scout_web/assets/ && \
    npm install && \
    npm run deploy && \
    cd -

RUN cd apps/explorer/ && \
    npm install && \
    apk update && apk del --force-broken-world alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3

RUN mix phx.digest
