#!/bin/bash

isbn_array=($@);

img_path=/media/img;
#casename=`echo ${isbn_array[@]} | grep -Eo "casename=[^\ & ^\\]*(\\\ [^\ & ^\\]*)*" | head -n 1 | sed -e "s/casename=//g"`;
casename="";

for isbn in ${isbn_array[@]}
do
  isbn_url="https://api.douban.com/v2/book/isbn/$isbn";

  book_info=`curl $isbn_url`;

  title=`echo $book_info | jq .title`;  # 标题

  subtitle=`echo $book_info | jq .subtitle`;  # 子标题

  author="[";   # 作者
  for ((i=0;;i=$i+1))
  do
    author_temp=`echo $book_info | jq ".author[$i]"`;
	  if [[ $author_temp != "null" ]]; then
	    if [[ $i -eq 0 ]]; then
		    author=$author$author_temp;
		  else
		    author=$author,$author_temp;
		  fi
	  else
		  author="$author]";
		  break;
	  fi
  done

  price=`echo $book_info | jq .price`; # 价格

  translator="[";  # 译者
  for ((i=0;;i=$i+1))
  do
	  translator_temp=`echo $book_info | jq ".translator[$i]"`;
	  if [[ $translator_temp != "null" ]]; then
	    if [[ $i -eq 0 ]]; then
		    translator=$translator$translator_temp;
		  else
		    translator=$translator,$translator_temp;
	    fi
	  else
		  translator="$translator]";
		  break;
    fi
  done


  publish_company=`echo $book_info | jq .publisher`; # 发行公司

  publish_date=`echo $book_info | jq .pubdate | sed -e "s/[\"\']//g"`;  # 发行日期

  if [[ -n `echo $publish_date | grep -o "\-[^\-]*\-"` ]]; then
	  publish_date=`date -j -f %Y-%m-%d $publish_date +%Y-%m-%d`;
  elif [[ -n `echo $publish_date | grep -o "\-"` ]]; then
	  publish_date=`date -j -f %Y-%m $publish_date +%Y-%m`;
  else
	  publish_date=`date -j -f %Y $publish_date +%Y`;
  fi
  	#statements


#isbn=`echo $book_info | jq .isbn13 | sed -e "s/[\"\']//g"`;  # isbn号
  douban_url=`echo $book_info | jq .alt`;  # 豆瓣链接

  cover_path=`echo $book_info | jq .images.large | sed -e "s/[\"\']//g"`;  # 封面图片
	img_name=`echo $cover_path | grep -o "[^/]*$" | sed -e "s/[\"\']//g"`;
	img_suffix=`echo $cover_path | grep -o "[^\.]*$" | sed -e "s/[\"\']//g"`;
	wget $cover_path;
	new_name=$isbn.$img_suffix;
	mv $img_name $new_name;

  filename=`date "+%Y-%m-%d"`-$isbn.md; # 文件名

	if [[ -f $filename ]]; then
		rm $filename;
	fi
  touch $filename;

  echo "---" >> $filename;
  echo "layout: post" >> $filename;  # 布局，jekyll-page使用
  echo "title: $title" >> $filename;
  echo "subtitle: $subtitle" >> $filename;
  echo "casename: $casename" >> $filename;  # 分类
  echo "author: $author" >> $filename;
  echo "donor: " >> $filename;  # 捐献者——图书馆使用
  echo "price: $price" >> $filename;
  echo "translator: $translator" >> $filename;
  echo "publish_company: $publish_company" >> $filename;
  echo "publish_version: " >> $filename;  # 发行版本
  echo "publish_date: $publish_date" >> $filename;
  echo "isbn: $isbn" >> $filename;
  echo "serial: " >> $filename;      # 图书分类号——图书馆使用
  echo "total_volume: 1" >> $filename;  # 总册数——图书馆使用
  echo "borrower: []" >> $filename;  # 借阅人——图书馆使用，数组
  echo "borrow_date: []" >> $filename;   # 借阅日期——图书馆使用，数组，同借阅人一一对应
  echo "douban_url: $douban_url" >> $filename;
  echo "cover_path: $img_path/$new_name" >> $filename;
  echo "tag: []" >> $filename;  # 标签
  echo "read_status: 想读/读过" >> $filename;  # 阅读状态
  echo "---" >> $filename;

  perl -p -i -e "s/\"//g" ./$filename;


done
