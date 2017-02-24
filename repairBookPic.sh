#!/bin/bash

curl "https://api.douban.com/v2/book/isbn/$1" > tmp_file;
wget `cat tmp_file | jq .images.large | sed -e "s/\"//g"`;
mv *.jpg bookcase/media/img/$1.jpg;
