# exit if any command fails
set -o errexit
# error if using an unitialized varaible
set -o nounset

# formatting mindwizardry
bold="\e[1m"
clr_gray="\e[0;38;5;240m"
clr_blue="\e[0;38;5;17m" # blue
clr_reset="\e[m"
function msg { echo; printf "${clr_gray}${1}${clr_reset}\n"; }
function hdr { msg "${bold}${1}"; }

# print command (in blue) before running
function run {
  printf "${clr_blue}${@}${clr_reset}\n"
  eval "$@"
}
