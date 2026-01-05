#!/bin/bash
set -e

PROJECT_ID=$1
LOCATION=$2
INTEGRATION_NAME=$3
JSON_FILE=$4

if [[ -z "$PROJECT_ID" || -z "$LOCATION" || -z "$INTEGRATION_NAME" || -z "$JSON_FILE" ]]; then
  echo "Usage: $0 <PROJECT_ID> <LOCATION> <INTEGRATION_NAME> <JSON_FILE>"
  exit 1
fi

echo "Getting access token..."
ACCESS_TOKEN=$(gcloud auth print-access-token)

# 1. Check if the integration (parent resource) exists
echo "Checking if integration $INTEGRATION_NAME exists in $LOCATION..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/integrations/$INTEGRATION_NAME")

if [ "$HTTP_STATUS" -eq 404 ]; then
  echo "Integration $INTEGRATION_NAME does not exist. Creating it..."
  curl -s -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"projects/$PROJECT_ID/locations/$LOCATION/integrations/$INTEGRATION_NAME\"}" \
    "https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/integrations?integrationId=$INTEGRATION_NAME"
elif [ "$HTTP_STATUS" -ne 200 ]; then
  echo "Failed to check integration existence. HTTP Status: $HTTP_STATUS"
  exit 1
fi

# 2. Create a new version
echo "Creating new version for $INTEGRATION_NAME..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @"$JSON_FILE" \
  "https://integrations.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/integrations/$INTEGRATION_NAME/versions")

VERSION_NAME=$(echo "$RESPONSE" | jq -r '.name')

if [[ "$VERSION_NAME" == "null" || -z "$VERSION_NAME" ]]; then
  echo "Error creating version: $RESPONSE"
  exit 1
fi

echo "Version created: $VERSION_NAME"

# 3. Publish the version
echo "Publishing version $VERSION_NAME..."
# Extract just the version relative name (e.g. integrations/NAME/versions/ID) for the publish endpoint
# The VERSION_NAME is usually "projects/PROJ/locations/LOC/integrations/NAME/versions/ID"
# The publish endpoint expects: https://integrations.googleapis.com/v1/{name=projects/*/locations/*/integrations/*/versions/*}:publish
PUBLISH_URL="https://integrations.googleapis.com/v1/$VERSION_NAME:publish"

PUBLISH_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  "$PUBLISH_URL")

# Check if publish response contains an error or if it's successful (successful publish returns a wrapper or empty JSON if void)
if echo "$PUBLISH_RESPONSE" | jq -e '.error' > /dev/null; then
  echo "Error publishing version: $PUBLISH_RESPONSE"
  exit 1
fi

echo "Integration $INTEGRATION_NAME published successfully!"
