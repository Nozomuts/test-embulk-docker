
FROM amazoncorretto:8

WORKDIR /app

ENV EMBULK_VERSION=0.11.2
ENV JRUBY_VERSION=9.4.5.0

RUN yum install -y shadow-utils mysql jq && \
    yum clean all

RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup appuser

RUN curl -o ./embulk.jar -L https://dl.embulk.org/embulk-${EMBULK_VERSION}.jar && \
    curl -o ./jruby-complete.jar -L https://repo1.maven.org/maven2/org/jruby/jruby-complete/${JRUBY_VERSION}/jruby-complete-${JRUBY_VERSION}.jar && \
    chmod +x ./embulk.jar ./jruby-complete.jar

COPY --chown=appuser:appgroup ./embulk.properties /home/appuser/.embulk/embulk.properties
RUN chown -R appuser:appgroup /app

USER appuser

RUN java -jar ./embulk.jar gem install embulk -v ${EMBULK_VERSION} && \
    java -jar ./embulk.jar gem install embulk-output-bigquery embulk-filter-column embulk-input-s3 embulk-input-mysql liquid msgpack
