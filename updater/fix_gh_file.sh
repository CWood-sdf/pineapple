cat $1 | sed "1 s/.*/[\0/" > outtmp.json

vim outtmp.json -c "%s/}\n{/},\r{/g" -c "wq"

echo "]" >> outtmp.json

cat outtmp.json > $1

rm outtmp.json
