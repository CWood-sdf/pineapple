#!/bin/bash

cd updater

bash ./scrape_gh.sh

bash ./scrape_neovimcraft.sh

cargo run --release -- clean-import

cargo run --release -- make-color-data
