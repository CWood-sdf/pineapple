#!/usr/bin/env bash

bash ./scrape_gh.sh

bash ./scrape_neovimcraft.sh

cargo run --release -- clean-import

cargo run --release -- make-color-data

cargo run --release -- generate-ts

cargo run --release -- generate-no-ts

cargo run --release -- move-to-lua
