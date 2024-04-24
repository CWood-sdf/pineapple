#!/bin/bash

cd updater

cargo run --release -- move-to-lua

cd ..

rm lua/pineapple/data.lua

cp updater/data.lua lua/pineapple/data.lua
