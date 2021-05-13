#!/usr/bin/env zsh
# Script used to extract themes from the original theme.sh repo
#   and separate them into individual files
mkdir -p themes
while read line
do 
  if ! [[ "$line" =~ .*:.* ]] then 
    if ! [[ -z "$line" ]] then 
      theme="$line"
      echo -n > themes/$theme
    fi
  else
    echo "$line" >> themes/$theme
  fi 
done < themes.txt
