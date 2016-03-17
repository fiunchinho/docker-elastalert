FROM gliderlabs/alpine:edge

MAINTAINER Jose Armesto <jose@armesto.net>

ENV LANG C.UTF-8
ENV ELASTALERT_HOME /opt/elastalert
ENV RULES_DIRECTORY ${ELASTALERT_HOME}/rules

WORKDIR /opt

RUN apk add --update \
    ca-certificates \
    python \
    python-dev \
    py-pip \
    build-base \
  && rm -rf /var/cache/apk/*

# RUN wget https://github.com/Yelp/elastalert/archive/master.zip && \
RUN wget https://github.com/fiunchinho/elastalert/archive/feature/signed_create_index_request.zip && \
    unzip -- *.zip && \
    mv -- elast* ${ELASTALERT_HOME} && \
    rm -- *.zip

WORKDIR ${ELASTALERT_HOME}

# Install Elastalert.
RUN python setup.py install && \
    pip install -e . && \
    mkdir ${RULES_DIRECTORY} && \
    cp ${ELASTALERT_HOME}/config.yaml.example config.yaml


ENTRYPOINT ["/opt/elastalert/docker-entrypoint.sh"]
CMD ["python", "elastalert/elastalert.py", "--verbose"]

COPY ./docker-entrypoint.sh ${ELASTALERT_HOME}/docker-entrypoint.sh
ADD ./rules/* ${RULES_DIRECTORY}/