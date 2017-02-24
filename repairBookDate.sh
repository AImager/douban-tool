#!/bin/bash

mulu=`ls `;

for mu in $mulu
do
  publish_date=`grep -o "publish_date:\ [^\ ]*" $mu | sed -e "s/publish_date:\ //g"`;
  
	if [[ -n `echo $publish_date | grep -o "\-[^\-]*\-"` ]]; then
	  publish_date=`date -j -f %Y-%m-%d $publish_date +%Y-%m-%d`;
	elif [[ -n `echo $publish_date | grep -o "\-"` ]]; then
	  publish_date=`date -j -f %Y-%m $publish_date +%Y-%m`;
	else
		publish_date=`date -j -f %Y $publish_date +%Y`;
	fi
	
	perl -p -i -e "s/publish_date:\ [^\ ]*/publish_date:\ $publish_date\n/g" $mu;
done
