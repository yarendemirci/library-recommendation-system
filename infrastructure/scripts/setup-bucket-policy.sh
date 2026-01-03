#!/bin/bash

BUCKET_NAME="library-app-frontend-780522923898"

echo "Setting up bucket policy for $BUCKET_NAME..."

# Create policy file
cat > /tmp/bucket-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::library-app-frontend-780522923898/*"
    }
  ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy file:///tmp/bucket-policy.json

echo "Bucket policy applied successfully!"
echo "Website URL: http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com"
