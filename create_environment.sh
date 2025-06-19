#!/bin/bash

#User must input their name (Will be needed to create the folder)

read -p "Enter your name: " divin
DIR="submission_reminder_$divin"

if [ -z "$divin" ]; then
    echo "Please enter your name."
    echo "The input is empty."
    exit 1
fi

# Letters only

if ! [[ "$divin" =~ ^[a-zA-Z\s]+$ ]]; then
	echo "You must write the name."
	echo "------------------------"
	echo "ending..."
	echo "------------------------"
	exit 1
fi

# Making folder/directory

if [ -d "$DIR" ]; then
    echo "The Directory already has been created"
    exit 1
else
    mkdir -p "$DIR"
    echo "The Directory '$DIR' has been successful created"
    echo "_________________"
    echo "Saving up the environment under '$DIR' Directory"
fi

# Making subdirectories

mkdir -p "$DIR/app"
mkdir -p "$DIR/modules"
mkdir -p "$DIR/assets"
mkdir -p "$DIR/config"

# Empty files 

[ ! -f "$DIR/app/reminder.sh" ] && touch "$DIR/app/reminder.sh"
[ ! -f "$DIR/modules/functions.sh" ] && touch "$DIR/modules/functions.sh"
[ ! -f "$DIR/assets/submissions.txt" ] && touch "$DIR/assets/submissions.txt"
[ ! -f "$DIR/config/config.env" ] && touch "$DIR/config/config.env"
[ ! -f "$DIR/startup.sh" ] && touch "$DIR/startup.sh"

echo '
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
' >> $DIR/app/reminder.sh

echo '
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
' >> $DIR/modules/functions.sh

echo '
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
' >> $DIR/assets/submissions.txt

echo '
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
' >> $DIR/config/config.env

cat <<EOL >> "$DIR/assets/submissions.txt"
Bonheur, Git, not submitted
Divin, Shell Navigation, submitted
Oleg, Git, not submitted
Scott, Shell Basics, not submitted
Audrey, Shell Navigation, submitted
EOL

# Creating codes to run reminder.sh

cat << 'EOL' > "$DIR/startup.sh"
#!/bin/bash

cd "$(dirname "$0")"
bash ./app/reminder.sh
EOL

# Executing them

# Filtering '.sh' files and adding execution commands

chmod +x "$DIR/app/reminder.sh"
chmod +x "$DIR/modules/functions.sh"
chmod +x "$DIR/startup.sh"
