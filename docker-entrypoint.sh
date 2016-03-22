#!/bin/sh

set -e

rules_directory=${RULES_FOLDER:-/opt/elastalert/rules}
es_port=${ELASTICSEARCH_PORT:-9200}
aws_region=${AWS_REGION:-eu-west-1}
use_ssl=${USE_SSL:-False}

# Render config file
cat config.yaml | sed "s|es_host: [[:print:]]*|es_host: ${ELASTICSEARCH_HOST}|g" | sed "s|es_port: [0-9]*|es_port: $es_port|g" | sed "s|aws_region: [[:print:]]*|aws_region: $aws_region|g" | sed "s|use_ssl: [[:print:]]*|use_ssl: $use_ssl|g" | sed "s|rules_folder: [[:print:]]*|rules_folder: $rules_directory|g" > config.yaml.tmp
cat config.yaml.tmp > config.yaml
rm config.yaml.tmp

# Render rules files
for file in $(find $rules_directory -name '*.yaml' -or -name '*.yml');
do
    cat $file | sed "s|SNS_TOPIC_ARN|${SNS_TOPIC_ARN}|g" | sed "s|AWS_REGION|$aws_region|g" | sed "s|BOTO_PROFILE|${BOTO_PROFILE}|g" > rule
    cat rule > $file
    rm rule
done

if ! wget ${es_host}:${es_port}/elastalert_status 2>/dev/null
then
	echo "Creating Elastalert index in Elasticsearch..."
    elastalert-create-index --index elastalert_status --old-index "" --no-auth
else
    echo "Elastalert index already exists in Elasticsearch."
fi

exec "$@"