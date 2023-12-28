cat $1 | jq '.[].items|.[] as $x | {repo_url: $x.full_name, stars: $x.stargazers_count, description: $x.description}' > outtmp.json
cat outtmp.json > $1
sh ./fix_gh_file.sh $1
