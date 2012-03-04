#!/bin/bash

# TODO: heavy header doc of process

# TODO: error guards (file presence tests)
# * rsa public key
# * stdin not blank

ssh_dir=${ssh_dir:=$HOME/.ssh}

# TODO: guard against useless repeats
# Convert the key to PEM format
ssh-keygen -f $ssh_dir/id_rsa.pub -e -m PKCS8 > $ssh_dir/id_rsa.pub.pkcs8

echo "-- Generated with Crypty 0.1 --"

email=`cat $ssh_dir/id_rsa.pub | awk '{print $3}'`
echo "-- PKCS8 formatted RSA public key for: $email --"

base64_pkcs8_public_key=`cat $ssh_dir/id_rsa.pub.pkcs8 | grep -v \- | cat`
for line in $base64_pkcs8_public_key ; do echo "P: $line" ; done

random_nonce=`head -c 20 /dev/random | xxd -p` # 160 bits (20 bytes) hex encoded

echo "-- Random nonce encrypted with above key --"
base64_rsa_encrypted_nonce=`echo -n $random_nonce |
  openssl rsautl -encrypt -inkey $ssh_dir/id_rsa.pub.pkcs8 -pubin |
  base64 --break 64`
for line in $base64_rsa_encrypted_nonce ; do echo "K: $line" ; done

echo "-- Body encrypted with AES-256-CBC using above nonce as the key --"
openssl enc -aes-256-cbc -e -nosalt -pass pass:$random_nonce -in /dev/stdin |
  base64 --break 67 > /dev/stdout
