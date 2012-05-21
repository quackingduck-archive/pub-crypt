# Exit if any command fails
set -o errexit
# Error if using an unitialized varaible
set -o nounset

# Override default value (~/.ssh) to fixture dir
export ssh_dir="test/fixtures/ssh"
# Setup scratch dir for test to write files
rm -rf tmp ; mkdir -p tmp

# Colors
gray="0;38;5;240"
blue="0;38;5;17"

# With arg: starts painting that color. With no arg: resets the brush.
# arg should be an ansi or x-term color string
# Eg: `clr 34` returns the string: "\e[34m"
function clr {
  local esc='\e' begin='[' end='m'; printf ${esc}${begin}${1:-}${end};
}
# Prints string using first arg as color
function clr-echo {
  local args=("$@"); printf "$(clr $1)${args[@]:1}$(clr)\n"
}

# Print info
function msg { echo; clr-echo $gray "$@"; }
# Print command (in blue) then run it
function run { clr-echo $blue $@ ; eval "$@"; }
# Compute hexdigest of file and print first 7 chars
function short_hash { echo `shasum $1 | head -c 7`; }
