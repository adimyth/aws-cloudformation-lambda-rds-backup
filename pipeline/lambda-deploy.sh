FUNCTION_NAME="lambda-rds-to-s3-backup"
BUCKET_NAME="lambda-rds-to-s3-backup-s3-bucket"
RULE_NAME="lambda-rds-to-s3-backup-cron-rule"
EVENT_NAME="lambda-rds-to-s3-backup-cron-event"

checkForLambda() {
    aws lambda get-function --function-name $FUNCTION_NAME
}

lambdaExt=$(checkForLambda)

execOnExist() {
    aws lambda update-function-code --function-name "$FUNCTION_NAME" --image-uri "$IMAGE_URI" --publish
}

execOnNotExist() {
    # Create lambda function
    lambda=$(aws lambda create-function --function-name "$FUNCTION_NAME" --role "$LAMBDA_ROLE" --code "ImageUri=$IMAGE_URI" --package-type Image --region "$AWS_REGION" --vpc-config "SubnetIds=subnet-093ddff71b52b991d,subnet-0e077ea1638249135,SecurityGroupIds=sg-06ef17860bccbda25,sg-0ab932b6a62e816b2" --timeout 30 --memory-size 1024 --publish | jq --raw-output '.FunctionArn')
    echo "\n\n"
    echo "Lambda Function ARN: "$lambdarnid

    # Create S3 bucket to store the database dump files
    aws s3 mb s3://"$BUCKET_NAME"

    # Create event rule to schedule a cron expression every 12 hours
    rule=$(aws events put-rule --name "$RULE_NAME" --description "Event rule to schedule a cron expression every 12 hours" --schedule-expression 'rate(12 hours)' --output text | grep "arn" | tr -d '"')
    echo "\n\n"
    echo "Event Rule ARN: "$rule

    # Grant permission to the rule to allow it to trigger the lambda function
    aws lambda add-permission --function-name "$FUNCTION_NAME" --statement-id "$EVENT_NAME" --action 'lambda:InvokeFunction' --principal events.amazonaws.com --source-arn arn:aws:events:ap-south-1:223865955266:rule/"$RULE_NAME"

    # Attach event rule to lambda as trigger event
    aws events put-targets --rule "$RULE_NAME" --targets '{"Id" : "1", "Arn": "$lambdarnid"}'
}

if [[ $lambdaExt ]]; then
    execOnExist
else
    execOnNotExist
fi
