#!/bin/sh
HOSTNAME=`echo "$@" | sed 's/\..*$//'`
( echo -n 'classes    = '; hiera classes    ::hostname=$HOSTNAME
  echo -n 'parameters = '; hiera parameters ::hostname=$HOSTNAME
  echo 'data = {"classes"=>classes, "parameters"=>parameters}'
  echo 'print data.to_yaml' ) \
| ruby -ryaml

