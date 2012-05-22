#!/bin/bash

# Encrypts stdin using the current user's private rsa key.

# Get the path to the user's public key. `ssh_dir` can be overidden in the
# calling environment but defaults to ~/.ssh
ssh_private_key_file=${ssh_dir:=$HOME/.ssh}/id_rsa
# Exit if the user has no public key
test -f $ssh_private_key_file ||
  { echo "error: couldn't find $ssh_private_key_file" >&2 ; exit 1; }

# Make a tempfile
header=`mktemp -t pub-crypt`
# Read a chunk of the stream into a tempfile. I've found that head on OS X
# seems to read pretty big chunks even when asked for little chunks (and then
# discards what it doesn't use). Reading 16384 seems to be a large enough
# chunk that it won't try to read past that.
head -c 16384 > $header

# Extract the base64 encoded key from the header
encrypted_key=`
  head -n 40 $header |
  grep 'K: ' |
  cut -d ' ' -f 2`

# Decrypt the key using the user's private rsa key
decrypted_key=`
  echo $encrypted_key |
  base64 --decode |
  openssl rsautl -decrypt -inkey $ssh_dir/id_rsa`

# And finally concatenate the header to the rest of stdin and decrypt that
cat $header - |
grep -v -e "[-:]" |
base64 --decode |
openssl enc \
  -aes-256-cbc -nosalt \
  -pass pass:$decrypted_key \
  -d
