. test/support.sh

msg Encrypting file
run "./encrypt.sh test/fixtures/lorem.txt > tmp/integration.pub-crypt"

msg Decrypting file
run "./decrypt.sh tmp/integration.pub-crypt > tmp/out.txt"

msg Validating
run [ $(short_hash test/fixtures/lorem.txt) = $(short_hash tmp/out.txt) ]

msg Encrypting stdin
run "cat test/fixtures/lorem.txt |
    ./encrypt.sh > tmp/integration.pub-crypt"

msg Decrypting stdin
run "cat tmp/integration.pub-crypt |
    ./decrypt.sh > tmp/out.txt"

msg Validating
run [ $(short_hash test/fixtures/lorem.txt) = $(short_hash tmp/out.txt) ]

msg File Format:
run "cat tmp/integration.pub-crypt"
