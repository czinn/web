#!/bin/bash

case $1 in
  h | help)
    echo $usage
    ;;
  b | build)
    wt compile -I css css/main.scss -s compressed -b static/css
    hugo
    rm -r out
    cp -r public out
    minify -aro out public
    ;;
  s | server)
    hugo server &
    wt watch -I css css/main.scss -s compressed -b static/css
    ;;
esac
