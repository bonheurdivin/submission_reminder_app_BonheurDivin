#!/bin/bash

# Requesting the user to input their name

read -p "Enter the environment folder name: " divin
if [ -z "$divin" ]; then
    echo "Please input the name"
    echo "---------------------"
    echo "Finalizing..."
    exit 1
fi
if ! [[ "$divin" =~ ^[a-zA-Z\s]+$ ]]; then
    echo "The environment folder name must include"
    echo "letters or name only"
    echo "Finalizing..."
    exit 1
fi
# Declaring variables

DIR="submission_reminder_$divin"
file1="$DIR/assets/submissions.txt"

if [ ! -d "$DIR" ]; then
    echo "Directory '$DIR' not found"
    echo "Please run create_environment.sh"
    echo "Finalizing..."
    exit 1
fi

# Requesting the user to input the assignment and the deadline

read -p "Input the Task name: " Summative
read -p "Enter the days remaining until deadline: " Days

# Sanitazing the variables input
Summative=$(echo "$Summative" | sed "s/$(echo -e '\u00a0')/ /g" | tr -cd '[:alnum:] [:space:]' | xargs)

Days=$(echo "$Days" | xargs)

echo "DEBUG: [$Summative]"

# Enter validation

if [ -z "$Summative" ] || ! [[ "$Days" =~ ^[0-9]+$ ]]; then
    echo "The Task name must not be empty"
    echo "and" 
    echo "The Days gotta be numbers"
    echo "-------------------------"
    echo "Finalizing..."
    exit 1
fi

if ! echo "$Summative" | grep -qE '^[A-Za-z ]+$'; then
    echo "The Task name must include" 
    echo "letters only"
    echo "Finalizing..."
    exit 1
fi

# Verifying if the Summative is present in submissions.txt

matched_task=$(grep -i ", *$Summative," "$file1" | awk -F',' '{print $2}' | head -n1 | xargs)

if [ -z "$matched_task" ]; then
    echo "Task '$Summative' isn't found in submissions.txt"
    echo "please retry"
    echo "Finalizing..."
    exit 1
fi

# Please update config.env

echo "Updating config.env in $DIR/config/"
echo "ASSIGNMENT=\"$matched_task\"" > "$DIR/config/config.env"
echo "DAYS_REMAINING=$Days" >> "$DIR/config/config.env"

echo "Configuration now up to date:"
cat "$DIR/config/config.env"

# Ask if the user wants to run the app

read -p "Would you like to run the reminder app immediately? (Y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "...Running the app..."
    bash "$DIR/startup.sh"
    echo "The app has already started and is currently running"
else
    echo "Reminder app wasn't started"
    echo "You may run it later with: bash $DIR/startup.sh"
fi
