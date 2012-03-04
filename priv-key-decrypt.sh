#!/bin/bash

ssh_dir=${ssh_dir:=$HOME/.ssh}

# assuming input from stdin, input from file won't need tempfile
filename=`mktemp -t pub-crypt`
cat /dev/stdin > $filename
# todo: trap and delete file

# 50 lines probably more than enough
# TODO: rename to base64_rsa_encrypted_nonce
key=`head -n 50 $filename | grep 'K: ' | cut -d ' ' -f 2`

# TODO: rename $dec_key
# TODO: die on failed password
dec_key=`echo $key | base64 --decode | openssl rsautl -decrypt -inkey $ssh_dir/id_rsa`

cat $filename | grep -v -e "[-:]" | base64 --decode | openssl enc -aes-256-cbc -d -nosalt -pass pass:$dec_key
