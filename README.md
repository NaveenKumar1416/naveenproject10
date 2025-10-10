LINUX USER CREATION AUTOMATION SCRIPT

Overview:
This project automates the process of creating and managing Linux users and groups for a growing developer team.
It was developed as part of a DevOps assessment task to demonstrate practical skills in Bash scripting, user management, and system automation.

Purpose:
The script simplifies user and group creation in bulk, ensuring proper setup, security, and logging for administrative tracking.

Key Features:
Reads usernames and group names from a text file.
Creates new users and their personal groups automatically.
Assigns users to additional specified groups.
Generates strong random passwords for each user.
Sets up home directories with correct permissions and ownership.
Logs all activities for auditing and troubleshooting.
Stores credentials securely for administrative reference.

How It Works:
The script reads a text file containing entries in the format
username;groupname
For each line, it performs the following actions:
Creates the specified group if it does not already exist.
Creates the user account and associates it with the group.
Adds the user to any additional groups listed.
Generates a random secure password.
Sets the password for the user.
Configures the home directory with appropriate permissions.
Logs all actions to the system log file for record-keeping.
