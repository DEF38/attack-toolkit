#!/bin/bash

prog=$(basename $0)
  
fn_help() {

    echo ""
    echo "Usage: $prog <subcommand> [options]"
    echo "Commands:"
    echo ""
    echo "    workstation-setup   Setup Docker & utilities on the workstation"
    echo "    upgrade             Upgrade attack environment to latest versions"
    echo "    up                  Launch the DEF38 attack environment"
    echo "    down                Stop the DEF38 attack environment"
    echo ""
    echo "For help with each subcommand run:"
    echo "$prog <subcommand> -h|--help"
    echo ""
}

fn_upgrade() {

    echo "Fetch latest versions"
    mkdir -p "$HOME/.def38"
    wget -q -O "$HOME/.def38/versions.json" https://raw.githubusercontent.com/DEF38/attack-toolkit/main/versions.json
    wget -q -O "$HOME/.def38/docker-compose.yaml" https://raw.githubusercontent.com/DEF38/attack-toolkit/main/docker-compose.yaml
}

fn_up() {

    fn_upgrade

    export DEF38_DNS_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".dns" |  tr -d '\n')
    export DEF38_WEB_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".web" |  tr -d '\n')
    export DEF38_API_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".api" |  tr -d '\n')
    export DEF38_TEST_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".test" |  tr -d '\n')
    export DEF38_SWIFT_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".swift" |  tr -d '\n')
    export DEF38_CLI_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".cli" |  tr -d '\n')

    # Remove before flight
    docker-compose -f $HOME/.def38/docker-compose.yaml up -d
}

fn_down() {

    export DEF38_DNS_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".dns" |  tr -d '\n')
    export DEF38_WEB_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".web" |  tr -d '\n')
    export DEF38_API_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".api" |  tr -d '\n')
    export DEF38_TEST_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".test" |  tr -d '\n')
    export DEF38_SWIFT_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".swift" |  tr -d '\n')
    export DEF38_CLI_VERSION=$(cat $HOME/.def38/versions.json | jq -r ".cli" |  tr -d '\n')

    # Remove before flight
    docker-compose -f $HOME/.def38/docker-compose.yaml down
}

fn_workstation-setup() {

    echo "Installing Docker CE & utilities"
    echo -e "\e[1m\e[92m(1/5) Prepare workstation\e[0m"
    sudo apt remove docker docker-engine docker.io containerd runc 2> /dev/null
    sudo apt update
    sudo apt install -y jq ca-certificates curl gnupg lsb-release

    echo -e "\e[1m\e[92m(2/5) Install Docker keyring\e[0m"
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo -e "\e[1m\e[92m(3/5) Add APT repository\e[0m"
    printf "%s\n" "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
    sudo apt update

    echo -e "\e[1m\e[92m(4/5) Install Docker CE\e[0m"
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    echo -e "\e[1m\e[92m(5/5) Post-installation steps\e[0m"
    sudo usermod -aG docker $USER
    echo 'Disconnect from current Kali session and launch new terminal'
    echo 'docker compose version'
}
  
subcommand=$1
case $subcommand in
    "" | "-h" | "--help")
        fn_help
        ;;
    *)
        shift
        fn_${subcommand} $@
        if [ $? = 127 ]; then
            echo "Error: '$subcommand' is not a known subcommand." >&2
            echo "       Run '$prog --help' for a list of known subcommands." >&2
            exit 1
        fi
        ;;
esac
