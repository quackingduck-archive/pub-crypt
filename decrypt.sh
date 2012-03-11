#!/bin/bash

ssh_dir=${ssh_dir:=$HOME/.ssh}

# TODO: guard against not having the right public key
# take

if [ $1 ]; then
  file_to_decrypt=$1
else
  # we need to seek into the stream to read the key
  file_to_decrypt=`mktemp -t pub-crypt`
  cat /dev/stdin > $file_to_decrypt
  # todo: trap and delete file
fi

encrypted_key=`
  head -n 40 $file_to_decrypt |
  grep 'K: ' |
  cut -d ' ' -f 2`

decrypted_key=`
  echo $encrypted_key |
  base64 --decode |
  openssl rsautl -decrypt -inkey $ssh_dir/id_rsa`

cat $file_to_decrypt |
grep -v -e "[-:]" |
base64 --decode |
openssl enc \
  -aes-256-cbc -nosalt \
  -pass pass:$decrypted_key \
  -d
