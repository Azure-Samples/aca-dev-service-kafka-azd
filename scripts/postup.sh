#!/bin/bash

while IFS='=' read -r key value; do
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    export "$key=$value"
done <<EOF
$(azd env get-values)
EOF

GREEN='\033[0;32m'
RESET='\033[0m'

echo ""
echo -e "\t${GREEN}Exec:${RESET} az containerapp exec -n $KAFKA_CLI_APP_NAME -g $RESOURCE_GROUP --command /bin/bash"
echo -e "\t${GREEN}Url:${RESET} $KAFKA_UI_URL"
