#!/bin/bash

queries=("vim theme" "vim color scheme" "vim colour scheme" "vim colourscheme" "vim colorscheme" "neovim color scheme" "neovim colorscheme" "neovim colour scheme" "neovim colourscheme" "neovim theme")

# skip=( 0 1 2 3)


for i in ${!queries[@]}; do
    if [[ " ${skip[@]} " =~ " ${i} " ]]; then
        continue
    fi
    query=$(echo ${queries[$i]} | sed "s/ /%20/g")
    filename="gh_out_$i.json"
    echo "Scraping $query into $filename"
    bash scrape_single_gh.sh $query $filename
done

# ls | grep gh_out_ | xargs sh ./refix_gh_file.sh

