#!/bin/bash

# Check if the current user is in the 'adm' group or is root
if [ "$(id -u)" -eq 0 ] || groups | grep -q "\badm\b"; then
  echo "User is already in adm group (or root). Running command..."
else
  echo "User is NOT in adm group."
  read -p "Would you like to add them? (y/N) " response
  case "$response" in
    [yY][eE][sS]|[yY])
      echo "Adding user to 'adm' group..."
      sudo usermod -aG adm "$USER"
      echo "User added. Note: changes require a re-login to take effect, but proceeding anyway."
      ;;
    *)
      echo "Proceeding without adding user to group."
      ;;
  esac
fi

# Execute the journalctl command
journalctl -u ollama --no-hostname -f
