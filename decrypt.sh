#!/bin/bash

ssh_dir=${ssh_dir:=$HOME/.ssh}

# TODO: guard against not having the right public key
# take

# assuming input from stdin, input from file won't need tempfile
filename=`mktemp -t pub-crypt`
cat /dev/stdin > $filename
# todo: trap and delete file

encrypted_key=`
  head -n 40 $filename |
  grep 'K: ' |
  cut -d ' ' -f 2`

decrypted_key=`
  echo $encrypted_key |
  base64 --decode |
  openssl rsautl -decrypt -inkey $ssh_dir/id_rsa`

cat $filename |
grep -v -e "[-:]" |
base64 --decode |
openssl enc \
  -aes-256-cbc -nosalt \
  -pass pass:$decrypted_key \
  -d
