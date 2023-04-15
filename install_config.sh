#!/bin/bash

# Setting variables

config=0
backup=0
user=""
verbose=false

# Option parsing

while getopts v option
do
    case "${option}"
        in
            v)verbose=true;;
    esac
done

# Utility functions

function confirm {
    if [[ ! $1 || $1 == "" ]];
    then
        echo ""
        echo "No confirmation question given"
        exit 3
    fi

    local iter=0

    while [[ $iter < 5 ]];
    do
        echo ""
        echo -n "$1 "
        read choice
        if [[ $choice == "y" || $choice == "Y" ]];
        then
            confim_result=true
            break
        elif [[ $choice == "n" || $choice == "N" ]];
        then
            confim_result=false
            break
        else
            echo ""
            echo "Bad input!"
        fi
        iter=$(( $iter + 1 ))
    done

}


# Select configuration

echo ""
echo -n "Please enter the configuration you want: "
read config

if [[ ! -d $config ]]; # If the given config does not exist
then
    echo ""
    echo "The given configuration dir '$config' doesn't exist"
    exit 1
fi


# Select if existing configs should be backed up or not

confirm "Do you want to backup existing configuration files? [y/n]"
backup=$confim_result

if [[ $backup == 0 ]];
then
    echo ""
    echo "No backup setting given, exiting..."
    exit 2
fi


# Get user to install config for

user=$(whoami)
echo ""
confirm "Do you want to install settings for user '$user'? [y/n]"

if ! $confim_result ;
then
    echo ""
    echo "Enter the user you want to install configurations for: "
    read user

    # Check if given user exists
    cut -d: -f1 /etc/passwd | grep $user &> /dev/null
    if [ $? -ne 0 ];
    then
        echo "Given user doesn't exist"
        exit 5
    fi

fi

# Final setting confirmation

echo ""
echo "Installation settings:"
echo "  Selected configuration: $config"
echo "  Will backup existing configuration files: $backup"
echo "  Install configurations for user: $user"
echo "  Verbose output: $verbose"

echo ""
confirm "Do you wish to proceed? [y/n]"

if ! $confim_result ;
then
    exit 4
fi

