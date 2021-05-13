#!/usr/bin/env zsh
# Script used to extract themes from the original theme.sh repo
#   and separate them into individual files
mkdir themes
while read line
do 
  if ! [[ "$line" =~ .*:.* ]] then 
    if ! [[ -z "$line" ]] then 
      theme="$line"
    fi
  else
    echo "$line" >> themes/$theme
  fi 
done < themes.txt
