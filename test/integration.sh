# ---

## Test Support

# exit if any command fails
set -o errexit
# error if using an unitialized varaible
set -o nounset

# formatting minwizardry
bold="\e[1m"
clr_gray="\e[0;38;5;240m"
clr_blue="\e[0;38;5;17m" # blue
clr_reset="\e[m"
function head { msg "${bold}${1}"; }
function msg { echo; printf "${clr_gray}${1}${clr_reset}\n"; }

# print command (in blue) before running
function run {
  printf "${clr_blue}${@}${clr_reset}\n"
  eval "$@"
}

# ---

## Tests

# todo: variables tmp path, fixtures path

head "Pub Crypt - Integration"

export ssh_dir="test/fixtures/ssh"

msg "Encrypting"
run "cat test/fixtures/lorem.txt |
    ./pub-key-encrypt.sh > tmp/integration.pub-crypt"
run "cat tmp/integration.pub-crypt"

msg "Decrypting"
run "cat tmp/integration.pub-crypt | ./priv-key-decrypt.sh"
echo
#
