#!/bin/bash

# Encrypts stdin using the current user's public rsa key.

# Get the path to the user's public key. `ssh_dir` can be overidden in the
# calling environment but defaults to ~/.ssh
ssh_pub_key_file=${ssh_dir:-$HOME/.ssh}/id_rsa.pub
# Exit if the user has no public key
test -f $ssh_pub_key_file ||
  { echo "error: couldn't find $ssh_pub_key_file" >&2 ; exit 1; }

# Path to PEM (pkcs8) formatted version of public key
pub_key_file=$ssh_pub_key_file.pkcs8
# Create PEM formatted if it doesn't already exits
test -f $pub_key_file ||
  ssh-keygen -f $ssh_pub_key_file -e -m PKCS8 > $pub_key_file

# Now we write the encypted file in Pub Crypt format to stdout
echo "-- Generated with Pub Crypt 1.0 -----------------------------------"

# The user's public key
email=`cut -f 3 -d ' ' $ssh_pub_key_file`
echo "-- Public key (RSA, PKCS8 format) for: $email"
base64_pkcs8_public_key=`grep -v \- $pub_key_file`
for line in $base64_pkcs8_public_key ; do
  echo "P: $line"
done

# 160 bits (20 bytes) of randomness, hex formatted
hex_encoded_random_key=`head -c 20 /dev/random | xxd -p`

# The random string encrypted with the user's public key
echo "-- Random key encrypted with public key above"
base64_encrypted_random_key=`
  echo -n $hex_encoded_random_key |
  openssl rsautl -encrypt -inkey $pub_key_file -pubin |
  base64 --break 64`
for line in $base64_encrypted_random_key ; do
  echo "K: $line"
done

# And finally we encrypt the stdin stream with that key and print it in
# base64 (in 67 char newline separated chunks)
echo "-- Body encrypted (AES-256-CBC) with random key above"
openssl enc \
  -aes-256-cbc \
  -nosalt \
  -pass pass:$hex_encoded_random_key \
  -e |
base64 --break 67

echo "-------------------------------------------------------------------"
