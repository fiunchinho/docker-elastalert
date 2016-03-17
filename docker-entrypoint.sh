#!/bin/sh

set -e

rules_directory=/opt/elastalert/rules

# Render config file
cat config.yaml | sed "s|es_host: [[:print:]]*|es_host: ${ELASTICSEARCH_HOST}|g" | sed "s|es_port: [0-9]*|es_port: ${ELASTICSEARCH_PORT}|g" | sed "s|rules_folder: [[:print:]]*|rules_folder: $rules_directory|g" > config.yaml.tmp
cat config.yaml.tmp > config.yaml
rm config.yaml.tmp

# Render rules files
for file in $(find $rules_directory -name '*.yaml' -or -name '*.yml');
do
    cat $file | sed "s|SNS_TOPIC_ARN|${SNS_TOPIC_ARN}|g" | sed "s|AWS_REGION|${AWS_REGION}|g" | sed "s|BOTO_PROFILE|${BOTO_PROFILE}|g" > rule
    cat rule > $file
    rm rule
done

if ! wget ${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/elastalert_status 2>/dev/null
then
	echo "Creating Elastalert index in Elasticsearch..."
    elastalert-create-index --index elastalert_status --old-index "" --host ${ELASTICSEARCH_HOST} --port ${ELASTICSEARCH_PORT}
else
    echo "Elastalert index already exists in Elasticsearch."
fi

exec "$@"