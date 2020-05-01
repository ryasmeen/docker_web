#!/bin/bash
if (($# == 0)); then
  echo "Please pass argumensts -w <website>... -p <port>.."
  exit 2
fi
while getopts ":w:p:" opt; do
  case $opt in
    w)
      echo "website: $OPTARG" >&2
      website=$OPTARG
      ;;
    p)
      echo "port: $OPTARG" >&2
      port=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

url="http://${website}:${port}"
attempts=2
timeout=2
online=false

echo "Checking status of $url."

for (( i=1; i<=$attempts; i++ ))
do
  code=`curl -sL --connect-timeout 20 --max-time 30 -w "%{http_code}\\n" "$url" -o /dev/null`

  echo "Found code $code for $url."

  if [ "$code" = "200" ]; then
    echo "Website $url is online."
    online=true
    break
  else
    echo "Website $url seems to be offline. Waiting $timeout seconds."
    sleep $timeout
  fi
done

if $online; then
  echo "Monitor finished, website is online."
  exit 0
else
  echo "Monitor failed, website seems to be down."
  exit 1
fi
