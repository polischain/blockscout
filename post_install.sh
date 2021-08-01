#!/bin/bash

# Migrate
mix do ecto.migrate

# Build static assets
cd apps/block_scout_web/assets && npm install && node_modules/webpack/bin/webpack.js --mode production


