#!/bin/bash

# color codes
RESTORE='\033[0m'
NC='\033[0m'
BLACK='\033[00;30m'
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
SEA="\\033[38;5;49m"
LIGHTGRAY='\033[00;37m'
LBLACK='\033[01;30m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
LBLUE='\033[01;34m'
LPURPLE='\033[01;35m'
LCYAN='\033[01;36m'
WHITE='\033[01;37m'
OVERWRITE='\e[1A\e[K'

#emoji codes
CHECK_MARK="${GREEN}\xE2\x9C\x94${NC}"
X_MARK="${RED}\xE2\x9C\x96${NC}"
PIN="${RED}\xF0\x9F\x93\x8C${NC}"
CLOCK="${GREEN}\xE2\x8C\x9B${NC}"
ARROW="${SEA}\xE2\x96\xB6${NC}"
BOOK="${RED}\xF0\x9F\x93\x8B${NC}"
HOT="${ORANGE}\xF0\x9F\x94\xA5${NC}"
WARNING="${RED}\xF0\x9F\x9A\xA8${NC}"
RIGHT_ANGLE="${GREEN}\xE2\x88\x9F${NC}"



set -e

# Paths
ID=""
DOTFILES_LOG="$HOME/.dotfiles.log"
DOTFILES_DIR="$HOME/.dotfiles"
SSH_DIR="$HOME/.ssh"
IS_FIRST_RUN="$HOME/.dotfiles_run"

function __task {
  # if _task is called while a task was set, complete the previous
  if [[ $TASK != "" ]]; then
    printf "${OVERWRITE}${LGREEN} [✓]  ${LGREEN}${TASK}\n"
  fi
  # set new task title and print
  TASK=$1
  printf "${LBLACK} [ ]  ${TASK} \n${LRED}"
}

# _cmd performs commands with error checking
function _cmd {
  #create log if it doesn't exist
  if ! [[ -f "$DOTFILES_LOG" ]]; then
    touch "$DOTFILES_LOG"
  fi
  # empty conduro.log
  > "$DOTFILES_LOG"
  # hide stdout, on error we print and exit
  if eval "$1" 1> /dev/null 2> "$DOTFILES_LOG"; then
    return 0 # success
  fi
  # read error from log and add spacing
  printf "${OVERWRITE}${LRED} [X]  ${TASK}${LRED}\n"
  while IFS= read -r line; do
    printf "      ${line}\n"
  done < "$DOTFILES_LOG"
  printf "\n"
  # remove log file
  rm -f "$DOTFILES_LOG"
  # exit installation
  exit 1
}

update_ansible_galaxy() {
  local os=$1
  local os_requirements=""
  __task "Updating Ansible Galaxy"
  if [ -f "$DOTFILES_DIR/requirements/$os.yml" ]; then
    __task "${OVERWRITE}Updating Ansible Galaxy with OS Config: $os"
    os_requirements="$DOTFILES_DIR/requirements/$os.yml"
  fi
  _cmd "ansible-galaxy install -r \"$DOTFILES_DIR/requirements/common.yml\" \"$os_requirements\""
}

function ubuntu_setup() {
  if ! dpkg -s ansible >/dev/null 2>&1; then
    __task "Installing Ansible"
    _cmd "sudo apt-get update"
    _cmd "sudo apt-get install -y software-properties-common"
    _cmd "sudo apt-add-repository -y ppa:ansible/ansible"
    _cmd "sudo apt-get update"
    _cmd "sudo apt-get install -y ansible"
    _cmd "sudo apt-get install python3-argcomplete"
    _cmd "sudo activate-global-python-argcomplete3"
  fi
  if ! dpkg -s python3 >/dev/null 2>&1; then
    __task "Installing Python3"
    _cmd "sudo apt-get install -y python3"
  fi

  local UBUNTU_MAJOR_VERSION=$(echo $VERSION_ID | cut -d. -f1)
  if [ $UBUNTU_MAJOR_VERSION -le 22 ]; then
    if ! dpkg -s python3-pip >/dev/null 2>&1; then
      __task "Installing Python3 Pip"
      _cmd "sudo apt-get install -y python3-pip"
    fi
    if ! pip3 list | grep watchdog >/dev/null 2>&1; then
      __task "Installing Python3 Watchdog"
      _cmd "sudo apt-get install -y python3-watchdog"
    fi
  fi
}

function macos_setup() {
  if ! [ -x "$(command -v brew)" ]; then
    __task "Installing Homebrew"
    _cmd "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  fi
  if ! [ -x "$(command -v git)" ]; then
    __task "Installing Git"
    _cmd "brew install git"
  fi
  if ! [ -x "$(command -v ansible)" ]; then
    __task "Installing Ansible"
    _cmd "brew install ansible"
  fi
}

detect_os() {
  if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo $ID
  else
    echo $(uname -s | tr '[:upper:]' '[:lower:]')
  fi
}

dotfiles_os=$(detect_os)
__task "Loading Setup for detected OS: $dotfiles_os"
case $dotfiles_os in
  ubuntu)
    ubuntu_setup
    ;;
  darwin)
    macos_setup
    ;;
  *)
    __task "Unsupported OS"
    _cmd "echo 'Unsupported OS'"
    ;;
esac

if [ -z "$SSH_EMAIL" ]; then
  SSH_EMAIL=$(git config --global user.email)
fi

if [ -z "$SSH_EMAIL" ]; then
  read -rp "Enter email to use for SSH key: " SSH_EMAIL
fi

echo "ssh email: $SSH_EMAIL"

if ! [[ -f "$SSH_DIR/authorized_keys" ]]; then
  __task "Generating SSH keys"
  _cmd "mkdir -p $SSH_DIR"
  _cmd "chmod 700 $SSH_DIR"
  _cmd "ssh-keygen -t ed25519 -f $SSH_DIR/id_ed25519_auth -N '' -C $SSH_EMAIL"
  _cmd "cat $SSH_DIR/id_ed25519_auth.pub >> $SSH_DIR/authorized_keys"
  _cmd "ssh-add $SSH_DIR/id25519_auth"
fi

if ! [[ -f "$SSH_DIR/known_hosts" ]]; then
  __task "Generating SSH known_hosts"
  _cmd "ssh-keyscan -H github.com >> $SSH_DIR/known_hosts"
fi

echo "$(ssh -T git@github.com)"

pushd "$DOTFILES_DIR" 2>&1 > /dev/null
update_ansible_galaxy $ID


ansible-playbook "$DOTFILES_DIR/main.yml" "$@" 

popd 2>&1 > /dev/null

if ! [[ -f "$IS_FIRST_RUN" ]]; then
  echo -e "${CHECK_MARK} ${GREEN}First run complete!${NC}"
  echo -e "${ARROW} ${CYAN}Please reboot your computer to complete the setup.${NC}"
  touch "$IS_FIRST_RUN"
fi

# vi:ft=sh:
