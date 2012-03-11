#!/bin/bash

# TODO: heavy header doc of process

# TODO: error guards (file presence tests)
# * rsa public key

file_to_encrypt=${1:-/dev/stdin}

# echo $file_to_encrypt
# exit

ssh_pub_key_file=${ssh_dir:-$HOME/.ssh}/id_rsa.pub
pub_key_file=$ssh_pub_key_file.pkcs8

# Convert the key to PEM format
test -f $pub_key_file ||
  ssh-keygen -f $ssh_pub_key_file -e -m PKCS8 > $pub_key_file

echo "-- Generated with Pub Crypt 1.0 -----------------------------------"

email=`cut -d ' ' -f 3 $ssh_pub_key_file`
echo "-- Public key (RSA, PKCS8 format) for: $email"

base64_pkcs8_public_key=`grep -v \- $pub_key_file`
for line in $base64_pkcs8_public_key ; do
  echo "P: $line"
done

hex_encoded_random_key=`head -c 20 /dev/random | xxd -p` # 160 bits (20 bytes)

echo "-- Random key encrypted with public key above"
base64_encrypted_random_key=`
  echo -n $hex_encoded_random_key |
  openssl rsautl -encrypt -inkey $pub_key_file -pubin |
  base64 --break 64`
for line in $base64_encrypted_random_key ; do echo "K: $line" ; done

echo "-- Body encrypted (AES-256-CBC) with random key above"
openssl enc \
  -aes-256-cbc \
  -nosalt \
  -pass pass:$hex_encoded_random_key \
  -e \
  -in $file_to_encrypt | base64 --break 67

echo "-------------------------------------------------------------------"
