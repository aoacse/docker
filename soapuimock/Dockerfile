# Dockerfile for building a soapui-runner
FROM openjdk

ENV SOAPUI_VERSION="5.4.0" \
  SOAPUI="/SoapUI-5.4.0/" \
  PROJECT_FILE="demoService-soapui-project.xml" \
  MOCKSERVICE_NAME="MockService" \
  MOCKSERVICE_PORT="8091" \
  PROJECT_FILE="demoService-soapui-project.xml" \
  MOCK_BIN="mockservicerunner.sh"

COPY SoapUI-5.4.0/ ./SoapUI-5.4.0/


ENV PATH="$PATH:$SOAPUI/bin"
COPY demoService-soapui-project.xml /demoService-soapui-project.xml
COPY entrypoint.sh /

EXPOSE 8091
RUN chmod 700 /entrypoint.sh
RUN chmod 770 $SOAPUI/bin/*.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
