set -e
install_ssh() {
    if ! which ssh >/dev/null; then
        brew install openssh-client
    fi
}

generate_ssh_key() {
    ssh-keygen -t ed25519 -C $1
}

check_ssh_keys() {
    read -p "Enter your email : " EMAIL
    generate_ssh_key $EMAIL || continue && return
}

add_ssh_key_to_ssh_agent() {
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
}

copy_ssh_key_then_add_to_github() {
    PERSONAL_ACCESS_TOKEN="ad5b3ada02f9c8cd652489e6fa6766aa9df14abb"
    SSH_KEY="$(cat ~/.ssh/id_ed25519.pub)"
    curl --header "Authorization: token $PERSONAL_ACCESS_TOKEN" -d '{"title":"ssh_key", "key": '$SSH_KEY' }' -X POST https://api.github.com/user/keys
}

# install_ssh && check_ssh_keys && add_ssh_key_to_ssh_agent
copy_ssh_key_then_add_to_github
