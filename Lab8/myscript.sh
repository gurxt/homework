#!/bin/bash

# Lab number: 8
# Student Name: Anthoyn Pisan
# Student Number: 041083663
# Course: CST7102 Section 300
# Submission Date: 2023-06-20
# Description: 
#	This program is a script file that enables the user to manager 
#   user and group management in Linux through the command line

# GLOBAL VARIABLES
BOLD=$(tput bold) ; RESET_BOLD=$(tput sgr0)  
GREEN='\033[0;32m' ; RED='\033[0;31m' ; ORANGE='\033[38;5;208m' ; RESET_COLOR='\033[0m'
SUPPRESS="2>/dev/null"
selection=0

# FUNCTIONS

# used to simulate a progress bar for executing a command.
fakeProgress () {
	local success=$1
	local result=$2

	echo -n -e "\n${BOLD}[${RESET_BOLD}"

	if [ $success -eq 0 ]; then
		for i in $(seq 1 40); do
			rand=$((RANDOM % 100 + 1))
			sleep $( echo "$rand / 100" | bc )
			echo -n "#"
		done
		echo -n -e "${BOLD}]${RESET_BOLD} - ${GREEN}success!${RESET_COLOR} $result\n"
	else
		while [ $((RANDOM % 15)) -ne 5 ]; do
			rand=$((RANDOM % 100 + 1))
			sleep $( echo "$rand / 100" | bc )
			echo -n "#"
		done
		echo -n -e "${RED}#~ failed!${RESET_COLOR} $result\n"
	fi
}

# the display menu
displayMenu () {
	clear
	# log the list of options for the user.
	echo -e "${BOLD}Choose one of the following options:\n${RESET_BOLD}"
	echo -e "\t${BOLD}A${RESET_BOLD} Create a user account"
	echo -e "\t${BOLD}B${RESET_BOLD} Change initial group for a user account"
	echo -e "\t${BOLD}C${RESET_BOLD} Change supplementary group for a user account"
	echo -e "\t${BOLD}D${RESET_BOLD} Change a defualt login shell for a user account"
	echo -e "\t${BOLD}E${RESET_BOLD} Change account expiration date for a user account"
	echo -e "\t${BOLD}F${RESET_BOLD} Delete a user account"
	echo -e "\t${BOLD}Q${RESET_BOLD} Quit\n"

	# prompt to select an option.
	read -p "Select option: " selection ; clear
}

# function for adding a user
addUser () {
	# 3 required user inputs
	read -p "${BOLD}Create username: ${RESET_BOLD}" username
	read -p "${BOLD}Create home directory: ${RESET_BOLD}" home
	read -p "${BOLD}Set default login shell: ${RESET_BOLD}" shell
	# run the command to add the user to the users list
	result=$(useradd -d "$home" -m -s "$shell" -N "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "$result"
	else
		fakeProgress 0 "user ${BOLD}$username${RESET_BOLD} has been created."
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function for changing a users initial group
changeInitialGroup () {
	# 2 required inputs
	read -p "${BOLD}Username: ${RESET_BOLD}" username
	read -p "${BOLD}Group name: ${RESET_BOLD}" group
	# run the command that changes the users initial group
	result=$(usermod -g "$group" "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "- $result"
	else
		fakeProgress 0 "- user ${BOLD}$username${RESET_BOLD}'s initial group has changed to ${BOLD}$group${RESET_BOLD}"
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function that adds a group to the users groups
addSupplementaryGroup () {
	# 2 required inputs
	read -p "${BOLD}Username: ${RESET_BOLD}" username
	read -p "${BOLD}Group name: ${RESET_BOLD}" group
	# run the command that adds a group to the users groups
	result=$(usermod -aG "$group" "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "- $result"
	else
		fakeProgress 0 "- added supplementary group ${BOLD}$group${RESET_BOLD} for user ${BOLD}$username${RESET_BOLD}"
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function that changes the default shell of the user
changeDefaultShell() {
	# 2 required inputs
	read -p "${BOLD}Username: ${RESET_BOLD}" username
	read -p "${BOLD}Shell name: ${RESET_BOLD}" shell
	# run the command that changes the users default shell
	result=$(chsh -s "$shell" "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "- $result"
	else
		fakeProgress 0 "${ORANGE}WARNING${RESET_COLOR} - linux does not validate the shell name you entered."
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function that validates a date string
validateDate () {
	local expiration=$1
	# get the current day month and year.
	curr_date=$(date +%Y-%m-%d)

	# convert both dates to timestamps for comparison. 
	curr_timestamp=$(date -d "$curr_date" +%s)
	expire_timestamp=$(date -d "$expiration" +%s 2>&1)

	# do validation on expire_timestamp to ensure the format entered is valid then
	# check to see if the expire_timestamp is greater than the current timestamp.
	if [ $? -ne 0 ] || [ "$curr_timestamp" -gt "$expire_timestamp" ]; then
		echo 1
	else
		echo 0
	fi
}

# function that changes the users expiration date
changeExpirationDate () {
	# 2 required inputs
	read -p "${BOLD}Username: ${RESET_BOLD}" username
	read -p "${BOLD}Expiration date (YYYY-MM-DD): ${RESET_BOLD}" expiration 
	# validate the date.
	if [ $(validateDate $expiration) -eq 1 ]; then 
		fakeProgress 1 "- invalid date entered. Date must be greater than the current date."
		sleep 3 
		return 1
	fi
	# run the command that changes the users expiration date
	result=$(usermod -e "$expiration" "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "- $result"
	else
		fakeProgress 0 "- expiration date change to ${BOLD}$expiration${RESET_BOLD} for user ${BOLD}$username${RESET_BOLD}."
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function that deletes user
deleteUser () {
	# 1 required input
	read -p "${BOLD}Username: ${RESET_BOLD}" username
	# run the command that deletes the user
	result=$(userdel -r "$username" 2>&1)
	# ensure that the command execute properly
	if [ $? -ne 0 ]; then
		fakeProgress 1 "- $result"
	else
		fakeProgress 0 "- user ${BOLD}$username${RESET_BOLD}'s account and home directory has been deleted."
	fi
	# sleep for 3 seconds
	sleep 3 
}

# function that validates user selection from the display menu
validateSelection () {
	local userSelection=$1

	case "$userSelection" in
		[Aa]) echo -e "OPTION [A] - Adding user\n"                        ; addUser ;;
		[Bb]) echo -e "OPTION [B] - Changing users initial group\n"       ; changeInitialGroup ;;
		[Cc]) echo -e "OPTION [C] - Adding supplementary group to user\n" ; addSupplementaryGroup ;;
		[Dd]) echo -e "OPTION [D] - Changing users default shell\n"       ; changeDefaultShell ;;
		[Ee]) echo -e "OPTION [E] - Changing users expiration date\n"     ; changeExpirationDate ;; 
		[Ff]) echo -e "OPTION [F] - Deleting users account\n"             ; deleteUser ;;
		[Qq]) return 1 ;; 
		*)    echo -e "OPTION [$userSelection] is invalid."               ; sleep 3
	esac
}

# loops until the user exits the program with a 'q' or 'Q' input
while [ "$selection" != "Q" ] && [ "$selection" != "q" ]; do
	displayMenu
	validateSelection "$selection"
done
