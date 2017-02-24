#!/bin/bash

movieid_array=($@);

img_path=/media/img;
casename="站着把钱挣了";

for movieid in ${movieid_array[@]}
do
  api_url="https://api.douban.com//v2/movie/subject/$movieid";
	home_url="http://movie.douban.com/subject/$movieid/";

	curl $home_url > html_file;

	grep "<span class=['\"]pl['\"]>编剧" html_file > tmp_file;
  playwright=[`sed -e "s/<[^>]*>//g" tmp_file | sed -e "s/ //g" | sed -e "s/编剧://g" | sed -e "s/\//,/g"`];

	grep "<span class=['\"]pl['\"]>语言" html_file > tmp_file;
	languages=[`sed -e "s/<[^>]*>//g" tmp_file | sed -e "s/ //g" | sed -e "s/语言://g" | sed -e "s/\/    /,/g" | sed -e "s/\//,/g"`];

  grep "<span class=['\"]pl['\"]>片长" html_file > tmp_file;
	durations=[`sed -e "s/<[^>]*>//g" tmp_file | sed -e "s/ //g" | sed -e "s/片长://g" | sed -e "s/\/    /,/g" | sed -e "s/\//,/g"`];

	movie_info=`curl $api_url`;

	title=`echo $movie_info | jq .title`; # 片中文名

  original_title=`echo $movie_info | jq ".original_title"`; # 片原名

	directors="[";    # 导演
	for ((i=0;;i=$i+1))
	do
	  directors_temp=`echo $movie_info | jq ".directors[$i].name"`;
		if [[ $directors_temp != "null" ]]; then
		  if [[ $i -eq 0 ]]; then
			  directors=$directors$directors_temp;
			else
				directors=$directors,$directors_temp;
			fi
		else
			directors="$directors]";
			break;
		fi
	done



  actors="[";        # 演员
  for ((i=0;;i=$i+1))
  do
	  actors_temp=`echo $movie_info | jq ".casts[$i].name"`;
	  if [[ $actors_temp != "null" ]]; then
	    if [[ $i -eq 0 ]]; then
		    actors=$actors$actors_temp;
		  else
		    actors=$actors,$actors_temp;
	    fi
	  else
		  actors="$actors]";
		  break;
    fi
  done



  publish_date=`echo $movie_info | jq .year`; # 制作发行年份


  countries="[";      # 制作发行地区
  for ((i=0;;i=$i+1))
  do
	  countries_temp=`echo $movie_info | jq ".countries[$i]"`;
	  if [[ $countries_temp != "null" ]]; then
	    if [[ $i -eq 0 ]]; then
		    countries=$countries$countries_temp;
		  else
		    countries=$countries,$countries_temp;
	    fi
	  else
		  countries="$countries]";
	  	break;
    fi
  done

  alias="[";   # 别名
  for ((i=0;;i=$i+1))
  do
    alias_temp=`echo $movie_info | jq ".aka[$i]"`;
	  if [[ $alias_temp != "null" ]]; then
	    if [[ $i -eq 0 ]]; then
		    alias=$alias$alias_temp;
		  else
		    alias=$alias,$alias_temp;
		  fi
	  else
		  alias="$alias]";
		  break;
	  fi
  done

  douban_url=`echo $movie_info | jq .alt`;  # 豆瓣地址

  douban_id=`echo $movie_info | jq .id | sed -e "s/\"//g"`;    # 豆瓣id号

	cover_path=`echo $movie_info | jq ".images.large" | sed -e "s/[\"\']//g"`;
	img_name=`echo $cover_path | grep -o "[^/]*$" | sed -e "s/[\"\']//g"`;
	img_suffix=`echo $cover_path | grep -o "[^\.]*$" | sed -e "s/[\"\']//g"`;
	wget $cover_path;
	new_name=$douban_id.$img_suffix;
	mv $img_name $new_name;


#if [[ $title != null ]]; then
    filename=`date "+%Y-%m-%d"`-$douban_id.md;  # 文件名
# else
#    filename=`date "+%Y-%m-%d"`-$douban_id.md;
#  fi

	if [[ -f $filename ]]; then
		rm $filename;
	fi
  touch $filename;


  echo "---" >> $filename;
  echo "layout: post" >> $filename;  # 布局，jekyll-page使用
  echo "title: $title" >> $filename;
  echo "original_title: $original_title" >> $filename;
  echo "alias: $alias" >> $filename;
  echo "casename: $casename" >> $filename;     # 分类
  echo "directors: $directors" >> $filename;
  echo "playwright: $playwright" >> $filename;
  echo "actors: $actors" >> $filename;
  echo "publish_date: $publish_date" >> $filename;
  echo "languages: $languages" >> $filename;
  echo "countries: $countries" >> $filename;
  echo "durations: $durations" >> $filename;
  echo "douban_url: $douban_url" >> $filename;
  echo "douban_id: $douban_id" >> $filename;
  echo "cover_path: $img_path/$new_name" >> $filename;
  echo "tag: " >> $filename;  # 标签
  echo "watch_status: 看过/想看" >> $filename;  ## 观看状态
  echo "---" >> $filename;

  perl -p -i -e "s/\"//g" ./$filename;
  rm html_file;
  rm tmp_file;
done
