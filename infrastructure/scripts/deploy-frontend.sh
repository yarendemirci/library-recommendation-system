#!/bin/bash

# CloudFront'a frontend deploy script'i
# Kullanım: ./infrastructure/scripts/deploy-frontend.sh

set -e

echo "🚀 Frontend CloudFront'a deploy ediliyor..."

# Root dizine git
cd "$(dirname "$0")/../.."

# Frontend build
echo "📦 Frontend build ediliyor..."
npm run build

# Stack output'larını al
echo "📋 CloudFront bilgileri alınıyor..."
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name LibraryFrontendStack \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name LibraryFrontendStack \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)

if [ -z "$BUCKET_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
  echo "❌ Stack output'ları alınamadı. Stack deploy edilmiş mi?"
  exit 1
fi

echo "📤 S3'e yükleniyor: $BUCKET_NAME"
aws s3 sync dist/ s3://$BUCKET_NAME/ --delete

echo "🔄 CloudFront cache temizleniyor: $DISTRIBUTION_ID"
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"

CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
  --stack-name LibraryFrontendStack \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontURL`].OutputValue' \
  --output text)

echo ""
echo "✅ Deploy tamamlandı!"
echo "🌐 CloudFront URL: $CLOUDFRONT_URL"
echo ""
echo "Not: CloudFront cache invalidation 5-10 dakika sürebilir."
