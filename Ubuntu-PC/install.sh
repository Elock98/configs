#!/bin/bash

# Variables

user=$1
backup_files=$2
verbose=$3
config_dir="$PWD/Ubuntu-PC"


# Functions

function checkprog {

    if ! command -v $1 &> /dev/null
    then
        echo "$1 is not installed, install it and try again"
        exit 3
    fi

}

function log {
    if $verbose == true;
    then
        echo $1
    fi
}

function setup_backup_dir {
    if [ ! -d "$config_dir/backups" ];
    then
        mkdir "$config_dir/backups"
    fi
}

function backup {
    # Check that an actual file was given
    local file=$1
    local file_path=$2
    if [ ! -f $file_path ];
    then
        echo "No file given to backup"
        exit 2
    fi

    # move file to backup dir
    cp $file_path "$config_dir/backups/$file"

}

# Check that initial variables are set

if [[ $user == "" || $backup_files == "" || $verbose == "" ]];
then
    echo "Initial variables not set correctly"
    exit 1
fi


# Backing up files

if $backup_files == true;
then
    log "Creating backup dir"
    setup_backup_dir

    log "Backing up .vimrc"
    backup ".vimrc" "/home/$user/.vimrc"

    log "Backing up .bashrc"
    backup ".bashrc" "/home/$user/.bashrc"

    log "Backing up .aliases"
    backup ".aliases" "/home/$user/.aliases"

    log ""
    log "Files have been backed up, they can be found in: $config_dir/backups/"

fi


# Install config files

# Vim

log ""
log "Installing vim config"

checkprog "vim"

if [ ! -f "/home/$user/.vim/autoload/plug.vim" ];
then
    log "Installing vim-plug"

    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # Change ownership of vim-plug to user

    chown -R "$user:$user" "/home/$user/.vim/autoload"
fi

log "Moving .vimrc to $user"
cp "$config_dir/.vimrc" "/home/$user/.vimrc"

log ""
echo "To install the vim plugins you need to enter :PlugInstall"
read
vim

# Bash

log ""
log "Installing bash config"

cp "$config_dir/.bashrc" "/home/$user/.bashrc"

log ""
log "Installing bash aliases"

cp "$config_dir/.aliases" "/home/$user/.aliases"

