. test/support.sh

msg Encrypting file
run "./pub-crypt -e test/fixtures/lorem.txt > tmp/integration.pub-crypt"

msg Decrypting file
run "./pub-crypt -d tmp/integration.pub-crypt > tmp/out.txt"

msg Validating
run [ $(short_hash test/fixtures/lorem.txt) = $(short_hash tmp/out.txt) ]

msg Encrypting stdin
run "cat test/fixtures/lorem.txt |
    ./pub-crypt -e > tmp/integration.pub-crypt"

msg Decrypting stdin
run "cat tmp/integration.pub-crypt |
    ./pub-crypt -d > tmp/out.txt"

msg Validating
run [ $(short_hash test/fixtures/lorem.txt) = $(short_hash tmp/out.txt) ]

msg File Format:
run "cat tmp/integration.pub-crypt"
