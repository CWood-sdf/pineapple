#!/bin/bash

mkdir ~/.config/nvim

cd updater

bash ./scrape.sh

cargo run --release -- make-color-data
