cmd="gh api /search/repositories?q='$1' --paginate" 

echo $cmd
echo $cmd | tee cmd2.txt | sh | jq . > $2

sh ./fix_gh_file.sh $2
