#!/bin/bash

cd updater
cargo run --release -- --thread-count 32 generate-no-ts
