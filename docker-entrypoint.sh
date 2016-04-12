#!/bin/sh

rules_directory=${RULES_FOLDER:-/opt/elastalert/rules}
es_port=${ELASTICSEARCH_PORT:-9200}
aws_region=${AWS_REGION:-''}
use_ssl=${USE_SSL:-False}
auth=${AUTH_METHOD:-''}

# Render rules files
for file in $(find . -name '*.yaml' -or -name '*.yml');
do
    cat $file | sed "s|es_host: [[:print:]]*|es_host: ${ELASTICSEARCH_HOST}|g" | sed "s|es_port: [[:print:]]*|es_port: $es_port|g" | sed "s|aws_region: [[:print:]]*|aws_region: $aws_region|g" | sed "s|boto_profile: [[:print:]]*|boto_profile: $BOTO_PROFILE|g" | sed "s|use_ssl: [[:print:]]*|use_ssl: $use_ssl|g" | sed "s|rules_folder: [[:print:]]*|rules_folder: $rules_directory|g" | sed "s|SNS_TOPIC_ARN|${SNS_TOPIC_ARN}|g" > config
    cat config > $file
    rm config
done

echo "Creating Elastalert index in Elasticsearch..."
if [[ "$auth" = "boto_profile" ]] ; then
    elastalert-create-index --index elastalert_status --old-index "" --no-auth --aws-region $aws_region --boto-profile $BOTO_PROFILE;
elif [[ "$auth" = "instance_role" ]] ; then
    elastalert-create-index --index elastalert_status --old-index "" --no-auth --aws-region $aws_region;
else
    elastalert-create-index --index elastalert_status --old-index "" --no-auth;
fi

exec "$@"