#!/usr/bin/env zsh
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
