# Ensure we are running from project root and tmp dir exists
cd `dirname $BASH_SOURCE`/..
. test/support.sh

# Use fixture instead of ~/.ssh
export ssh_dir="test/fixtures/ssh"
# Setup scratch dir for test to write files
rm -rf tmp ; mkdir -p tmp

head "Pub Crypt - Integration"

msg "Encrypting"
run "cat test/fixtures/lorem.txt |
    ./encrypt.sh > tmp/integration.pub-crypt"
run "cat tmp/integration.pub-crypt"

msg "Decrypting"
run "cat tmp/integration.pub-crypt | ./decrypt.sh"


