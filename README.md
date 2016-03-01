# Docker ElastAlert
Docker container for [Yelp's ElastAlert](https://github.com/Yelp/elastalert).

## Building
The rules defined in the `rules` folder will be added to the ElastAlert container on build time, so if you want to change your rules, a new version of the container must be built.

You can build the container like

```bash
$ docker build -t fiunchinho/docker-elastalert .
```

## Running
This container needs two environment variables when is running

- `ELASTICSEARCH_HOST`: ElasticSearch host to query
- `ELASTICSEARCH_PORT`: ElasticSearch port

So you can start this container like

```bash
$ docker run "-e "ELASTICSEARCH_HOST=some.elasticsearch.host.com" -e "ELASTICSEARCH_PORT=9200" fiunchinho/docker-elastalert
```

## Alerting
Depending on your desired alerts you may need to mount files into the container, like AWS credentials for SNS alerting or smtp configuration values for Email alerting.

### Email
Alerts using email need to specify the path to a file which contains SMTP authentication credentials. So you need to mount this file inside the container. If the file `email_credentials.yml` is inside your current folder and your rule expect it to be in `/tmp/email_credentials.yml`

```bash
$ docker run -v "$PWD/email_credentials.yml:/tmp/email_credentials.yml" "-e "ELASTICSEARCH_HOST=some.elasticsearch.host.com" -e "ELASTICSEARCH_PORT=9200" fiunchinho/docker-elastalert
```

### SNS
For example, if we want to alert using SNS we need to mount the AWS credentials with a boto profile with permissions to publish in the SNS topic

```bash
$ docker run -v "$HOME/.aws:/root/.aws" "-e "ELASTICSEARCH_HOST=some.elasticsearch.host.com" -e "ELASTICSEARCH_PORT=9200" fiunchinho/docker-elastalert
```
