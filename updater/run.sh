#!/usr/bin/env bash

# cargo run --release -- make-color-data

cargo run --release -- generate-ts

cargo run --release -- generate-no-ts

nvim --headless -c 'Lazy! sync' -c 'qa!'

nvim --headless -c 'TSUpdateSync' -c 'qa!'

nvim --headless -c 'TSInstallSync all' -c 'qa!'
