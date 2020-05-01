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
