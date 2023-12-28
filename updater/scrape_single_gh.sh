echo "gh api /search/repositories?q=$1 --paginate" | tee cmd2.txt | sh | jq . > $2

sh ./fix_gh_file.sh $2
