#!/bin/bash
# Generate traffic on orders-api and payment-service
# Usage: ./generate-traffic.sh [duration_seconds]

DURATION=${1:-60}
ORDERS_URL=http://localhost:3000
PAYMENT_URL=http://localhost:3002

echo "Generating traffic for ${DURATION} seconds..."

start=$(date +%s)
round=0
while [ $(($(date +%s) - start)) -lt $DURATION ]; do
  round=$((round + 1))

  # Orders API
  curl -sf -X POST $ORDERS_URL/api/simulate -H "Content-Type: application/json" -d '{"count":30}' > /dev/null &
  curl -sf -X POST $ORDERS_URL/api/orders -H "Content-Type: application/json" \
    -d "{\"customer\":\"User${round}\",\"items\":[\"Widget\"],\"total\":$((RANDOM % 1000))}" > /dev/null 2>&1 &
  curl -sf $ORDERS_URL/api/orders > /dev/null 2>&1 &

  # Payment Service
  curl -sf -X POST $PAYMENT_URL/api/simulate-payments -H "Content-Type: application/json" -d '{"count":30}' > /dev/null &
  curl -sf -X POST $PAYMENT_URL/api/charge -H "Content-Type: application/json" \
    -d "{\"cardNumber\":\"4111222233334444\",\"expiry\":\"12/28\",\"cvv\":\"123\",\"amount\":$((RANDOM % 1000)),\"customer\":\"User${round}\"}" > /dev/null 2>&1 &
  curl -sf $PAYMENT_URL/api/transactions > /dev/null 2>&1 &

  if (( round % 10 == 0 )); then
    elapsed=$(($(date +%s) - start))
    echo "  ${elapsed}s elapsed - ~$((round * 6)) requests sent..."
  fi

  sleep 1
done
wait

echo "Done. Sent ~$((round * 6)) requests over ${DURATION} seconds."
