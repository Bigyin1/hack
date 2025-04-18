for f in *.json; do wavedrom-cli -i $f -s ${f%%.*}.svg; done
