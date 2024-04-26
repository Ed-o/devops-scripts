# Get a list of all API Gateway APIs
apis=$(aws apigateway get-rest-apis --query 'items[].id' --output text)

# Calculate the start time
start_time=$(date -u -v -31d '+%Y-%m-%dT%H:%M:%SZ')

# Get the 5XXError metric for each API
for api in $apis; do
    result=$(aws cloudwatch get-metric-statistics \
        --namespace "AWS/ApiGateway" \
        --metric-name "5XXError" \
        --start-time "$start_time" \
        --end-time "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
        --period 3600 \
        --statistics "Sum" \
        --dimensions Name="ApiName",Value="$api" )
        # --query "sum(Sum)")

    if [ -z "$result" ]; then
        echo "No data available for API Gateway API: $api"
    else
        echo "$result"
    fi
done

