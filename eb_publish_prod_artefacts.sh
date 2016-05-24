

EB_APP_NAME=$1
SHA1=$2
AWS_DEV_ACCOUNT_ID=$3
AWS_PROD_ACCOUNT_ID=$4
EB_BUCKET=$5
AWS_PROD_PROFILE=$6

VERSION=$EB_APP_NAME-$SHA1
ZIP=$VERSION.zip
DEV_CONTAINER=$AWS_DEV_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$EB_APP_NAME:$SHA1
PROD_CONTAINER=$AWS_PROD_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$EB_APP_NAME:$SHA1

aws configure set default.region eu-west-1

# login to DEV ECR
echo "Login into Dev ECR"
login_command=$(aws ecr get-login)
eval sudo $login_command

echo "Pulling container $DEV_CONTAINER"
sudo docker pull $DEV_CONTAINER
sudo docker tag $DEV_CONTAINER $PROD_CONTAINER

# login to prod ECR
echo "Login to Prod ECR"
login_command=$(aws ecr get-login --profile $AWS_PROD_PROFILE)
eval sudo $login_command
echo "Pushing container $PROD_CONTAINER"
sudo docker push $PROD_CONTAINER

echo "Fetching $ZIP from Dev S3 $EB_BUCKET"
aws s3 cp s3://$EB_BUCKET/$ZIP $ZIP

echo "Processing files"
unzip $ZIP template.Dockerrun
mv template.Dockerrun Dockerrun.aws.json
sed -i "s/<AWS_ACCOUNT_ID>/$AWS_PROD_ACCOUNT_ID/" Dockerrun.aws.json
zip -d template.Dockerrun
zip -u $ZIP Dockerrun.aws.json

echo "Uploading $ZIP to Prod S3 $EB_BUCKET"
aws s3 cp $ZIP s3://$EB_BUCKET/$ZIP --profile $AWS_PROD_PROFILE

echo "Publishing application version $VERSION to Prod EB app $EB_APP_NAME"
# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name $EB_APP_NAME \
    --version-label $VERSION --description "Automated build" --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP --profile $AWS_PROD_PROFILE