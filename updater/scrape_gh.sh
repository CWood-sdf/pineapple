queries=("vim theme" "vim color scheme" "vim colour scheme" "vim colourscheme" "neovim theme" "neovim color scheme" "neovim colorscheme" "neovim colour scheme" "Vim Theme" "neovim colourscheme" "Neovim theme" "vim color scheme")

skip=(0 1 2 3 4 5 6 7 8 9 10 11)


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

