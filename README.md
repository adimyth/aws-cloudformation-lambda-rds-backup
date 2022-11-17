# RDS Database Backup to S3 using Lambda

Takes individual database backups in an RDS instance and pushes them to S3 periodically. Deployed as an AWS Lambda function and triggered by CronExpression.

🔐 User credentials are read from the SecretsManager service

**_Structure_**

- `rds-backup` - Code for the application's Lambda function and project Dockerfile
- `buildspec.yaml` - A template that defines the application's AWS resources.
- `pipeline/lambda-deploy.sh` - Script to deploy the pipeline
