#!/bin/bash

# Redirect stdout and stderr to tty1
exec > /dev/tty1 2>&1

# Redirect stdin to tty1 to capture key inputs
exec < /dev/tty1

# Hide the cursor for a cleaner display
echo -e "\033[?25l"

# Disable mouse reporting
echo -e "\033[?1000l"

# Ensure the cursor is shown again upon script exit
trap 'echo -e "\033[?25h"' EXIT

clear

# Allowed keys list for selecting network interfaces (1-9)
ALLOWED_KEYS=("1" "2" "3" "4" "5" "6" "7" "8" "9")

# Function to check if a key is allowed
is_allowed_key() {
    local key="$1"
    for allowed in "${ALLOWED_KEYS[@]}"; do
        if [[ "$allowed" == "$key" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to display the system status
display_system_status() {
    # Move cursor to top-left corner
    echo -e "\033[H"

    # Fetch current date and time
    echo "============================================================================="
    echo "DeEEP Network System Status - $(date)"
    echo "============================================================================="

    # Display the hostname of the device
    echo "Hostname: $(hostname)"
    echo ""

    # Check Internet Connectivity
    echo "Internet Connectivity:"
    if ping -c 1 google.com >/dev/null 2>&1; then
        echo "Connected to the Internet"
        echo "Public IP address: "
        wget -q -O - ipinfo.io/ip
        echo ""
    else
        echo "No Internet Connection"
    fi
    echo ""

    # Display System Load
    echo "System Load:"
    uptime
    echo ""

    # Show compact interface list using networkctl
    echo "Network Interfaces:"
    networkctl | grep -v links

}

while true; do
    # Display the system status
    display_system_status

    # Instructions
    echo ""
    echo "Select an interface by pressing its IDX number (1-9)."

    # Wait for user input to select an interface
    read -r -n1 -t5 key

    if is_allowed_key "$key"; then
        # Show detailed information for the selected interface
        clear
        display_system_status
        echo ""
        echo "Showing detailed status for interface $key:"
        networkctl status "$key"
        echo ""
    fi

    # Wait for a second before refreshing the list
    sleep 1
done
