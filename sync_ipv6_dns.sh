#!/bin/bash

# ===================== CONFIG =====================
API_KEY="your-actual-api-key"  #Replace this with your actual API key
RECORD_ID="-ID for the record to be updated"
RECORD_KEY="awesomehomeserver.dlt"
RECORD_TYPE="AAAA"
ENABLED=true
API_BASE="https://192.168.1.1/proxy/network/v2/api/site/default"
DNS_GET_URL="$API_BASE/static-dns"
DNS_UPDATE_URL="$API_BASE/static-dns/$RECORD_ID"

# ===================== FUNCTIONS =====================

get_local_ipv6() {
  ip -6 addr show scope global dynamic | grep inet6 | grep -v temporary | awk '{print $2}' | cut -d/ -f1 | head -n1
}

get_dns_record_ipv6() {
  curl -sk -X GET "$DNS_GET_URL" \
    -H "X-API-KEY: $API_KEY" \
    -H "Accept: application/json" | \
    jq -r '.[] | select(._id == "'$RECORD_ID'") | .value'
}

update_dns_record_ipv6() {
  local new_ip="$1"
  curl -sk -X PUT "$DNS_UPDATE_URL" \
    -H "X-API-KEY: $API_KEY" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{
      \"record_type\": \"$RECORD_TYPE\",
      \"value\": \"$new_ip\",
      \"key\": \"$RECORD_KEY\",
      \"_id\": \"$RECORD_ID\",
      \"enabled\": $ENABLED
    }"
}

# ===================== MAIN LOGIC =====================

LOCAL_IPV6=$(get_local_ipv6)

if [[ -z "$LOCAL_IPV6" ]]; then
  echo "No local global dynamic IPv6 address found."
  exit 1
fi

DNS_IPV6=$(get_dns_record_ipv6)

if [[ -z "$DNS_IPV6" ]]; then
  echo "Could not fetch DNS record value from UniFi gateway."
  exit 1
fi

echo "Local IPv6: $LOCAL_IPV6"
echo "DNS Record IPv6: $DNS_IPV6"

if [[ "$LOCAL_IPV6" == "$DNS_IPV6" ]]; then
  echo "IPv6 address is already up-to-date. No update needed."
else
  echo "Updating DNS record..."
  RESPONSE=$(update_dns_record_ipv6 "$LOCAL_IPV6")

  if echo "$RESPONSE" | jq -e '.value' >/dev/null 2>&1; then
    echo "DNS record updated successfully to $LOCAL_IPV6"
  else
    echo "Failed to update DNS record."
    echo "Response: $RESPONSE"
    exit 1
  fi
fi
