set -e
function install_ssh() {
    if ! which ssh >/dev/null; then
        echo -e "Command not found! Install? (y/n) \c"
        read
        if "$REPLY" = "y"; then
            brew install openssh
        fi
    fi
}

function generate_ssh_key() {
    ssh-keygen -t ed25519 -C $EMAIL
}

function check_ssh_keys() {
    $FILE "id_ed25519.pub"
    if [ ! -e "~/.ssh/$FILE" ]; then
        while true; do
            read -p "Enter your email : " EMAIL
            generate_ssh_key || continue && return
        done
    fi
}

function add_ssh_key_to_ssh_agent() {
    $SSH_CONTENT="Host * \
    AddKeysToAgent yes \
    UseKeychain yes \
    IdentityFile ~/.ssh/id_ed25519"
    eval "$(ssh-agent -s)"
    if [[ ! -e ~/.ssh/config ]]; then touch ~/.ssh/config; fi
    echo "$SSH_CONTENT" >>~/.ssh/config
    ssh-add -K ~/.ssh/id_ed25519
}

function copy_ssh_key_then_add_to_github() {
    PERSONAL_ACCESS_TOKEN="ad5b3ada02f9c8cd652489e6fa6766aa9df14abb"
    SSH_KEY=$(cat ~/.ssh/id_ed25519.pub)
    pbcopy <~/.ssh/id_ed25519.pub
    curl --header "Authorization: token $PERSONAL_ACCESS_TOKEN" -d '{"title":"testing", "key": '$SSH_KEY' }' -X POST https://api.github.com/user/keys
}

install_ssh && check_ssh_keys && add_ssh_key_to_ssh_agent && copy_ssh_key_then_add_to_github
