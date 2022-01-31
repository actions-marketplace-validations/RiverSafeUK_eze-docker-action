#!/bin/sh -l

cp -r . /data
cd /data

echo "" >> .ezerc.toml
echo "" >> .ezerc.toml
if [ $INPUT_UPLOAD_METHOD = "sarif" ]
then
    echo "printing in SARIF"
    echo "[sarif.github]" >> .ezerc.toml
    echo "REPORT_FILE = \"reports/eze.sarif\"" >> .ezerc.toml
    echo "" >> .ezerc.toml
    echo "[scan.github]" >> .ezerc.toml
    echo "reporters = [\"sarif:github\"]" >> .ezerc.toml
    echo "" >> .ezerc.toml
    eze test -s github
    echo ::set-output name=sarif_file::$(cat reports/eze.sarif)
else
    echo "printing in MARKDOWN"
    echo "[markdown.github]" >> .ezerc.toml
    echo "REPORT_FILE = \"reports/eze.md\"" >> .ezerc.toml
    echo "" >> .ezerc.toml
    echo "[scan.github]" >> .ezerc.toml
    echo "reporters = [\"markdown:github\"]" >> .ezerc.toml
    echo "" >> .ezerc.toml
    eze test -s github
    echo ::set-output name=markdown_file::$(cat reports/eze.md)
fi