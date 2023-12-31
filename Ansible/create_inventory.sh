#!/bin/bash
# Define an array of IP address files
IP_FILES=(
    "../terraform/master_ec2-ip.txt"
    "../terraform/worker_ec2-ip.txt"
    "../terraform/deployment_ec2-ip.txt"
    
    # Add more IP address files as needed
)

# Define an array of host group names
HOST_GROUPS=(
    "master_server"
    "worker_server"
    "deployment_server"
    # Add more host group names as needed
)

# Specify the combined inventory file
COMBINED_INVENTORY_FILE="inventory.txt"

# Check if the combined inventory file exists and clear its content
echo -n > "$COMBINED_INVENTORY_FILE"

# Iterate over IP files and host groups
for ((i=0; i<${#IP_FILES[@]}; i++)); do
    IP_FILE="${IP_FILES[i]}"
    HOST_GROUP="${HOST_GROUPS[i]}"

    # Check if the IP address file exists
    if [ ! -f "$IP_FILE" ]; then
        echo "Error: IP address file '$IP_FILE' not found."
        exit 1
    fi

    # Read the IP address from the file
    EC2_INSTANCE_IP=$(cat "$IP_FILE")

    # Check if the IP address is not empty
    if [ -z "$EC2_INSTANCE_IP" ]; then
        echo "Error: IP address is empty in '$IP_FILE'."
        exit 1
    fi

    # Append the information to the combined inventory file
    echo "[$HOST_GROUP]" >> "$COMBINED_INVENTORY_FILE"
    echo "$EC2_INSTANCE_IP ansible_ssh_private_key_file=/home/ec2-user/ec2_key.pem ansible_user=ec2-user" >> "$COMBINED_INVENTORY_FILE"

    echo "Inventory file updated with IP address: $EC2_INSTANCE_IP for group $HOST_GROUP"
done

echo "Combined inventory file created: $COMBINED_INVENTORY_FILE"
