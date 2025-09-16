#!/usr/bin/env bash
## Usage:
## Terraform output -json cluster_endpoints > cluster_endpoints.json 
## ./ansible_inventory.sh

ANSIBLE_DIR="../ansible"
KUBECONFIG_DIR="kubeconfig"

# Make sure kubeconfig dir exists
mkdir -p "$KUBECONFIG_DIR"

# Generate inventory.ini
cat <<EOF > "$ANSIBLE_DIR/inventory.ini"
[kubernetes_clusters]
EOF

# Loop through clusters and write inventory with kubeconfig
jq -r 'to_entries[] | "\(.key) ansible_host=\(.value | ltrimstr("https://")) kubeconfig='"$KUBECONFIG_DIR"'/\(.key)-kubeconfig.yaml"' cluster_endpoints.json >> "$ANSIBLE_DIR/inventory.ini"

# Add hub_cluster group
echo -e "\n[hub_cluster]" >> "$ANSIBLE_DIR/inventory.ini"
jq -r '"\(.hub) ansible_host=\(.hub | ltrimstr("https://")) kubeconfig='"$KUBECONFIG_DIR"'/hub-kubeconfig.yaml"' cluster_endpoints.json >> "$ANSIBLE_DIR/inventory.ini"

# Add spoke_clusters group
echo -e "\n[spoke_clusters]" >> "$ANSIBLE_DIR/inventory.ini"
for cluster in prod dev internal core; do
    host=$(jq -r --arg c "$cluster" '.[$c]' cluster_endpoints.json | sed 's|https://||')
    echo "$cluster ansible_host=$host kubeconfig=$KUBECONFIG_DIR/$cluster-kubeconfig.yaml" >> "$ANSIBLE_DIR/inventory.ini"
done

echo "inventory.ini generated successfully with cluster endpoints and kubeconfigs!"
