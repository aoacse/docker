#!/bin/bash

#
# Default usage: docker-entrypoint.sh start-soapui
#
# ==> Note: for the SoapUI command reference see http://www.soapui.org/test-automation/running-from-command-line/soap-mock.html
#

# Default value of environment variables:
#     PROJECT           = default-soapui-project.xml
#     MOCK_SERVICE_PATH = << unset >>  ; this implies that the path in the mockservice itself is used
#
#
# The following enviroment variable is required (and has no default value)
#     MOCKSERVICE_NAME = << unset >>
#


#
# Run entrypoint scripts of dependent docker containers
#
if [ -d /docker-entrypoint-initdb.d ]; then
    for f in /docker-entrypoint-initdb.d/*.sh; do
        [ -f "$f" ] && . "$f"
    done
fi


#
# Setup default values for environment variables.
#
if [ -z "$PROJECT" ]; then
    export PROJECT=demoService-soapui-project.xml
fi

if [ -z "$MOCKSERVICE_NAME" ]; then
    echo "Enviromentment variable MOCKSERVICE_NAME should have been set explicitly (e.g. by  -e MOCKSERVICE_NAME=BLZ-SOAP11-MockService"
    exit 1
fi

export PATH=$SOAPUI/bin:$PATH


# create a private pipe to simulate SoapUI's "Press any key to exit"
PIPE=$(mktemp -u)
mkfifo $PIPE
exec 3<>$PIPE
rm $PIPE

function stopSoapUi {
    echo "Stopping $MOCKSERVICE_NAME..."
    echo "Stop" >&3
}

trap stopSoapUi TERM INT

if [ "$1" = 'start' ]; then

    if [ -z "$MOCKSERVICE_PATH" ]; then
        echo "Starting Mock-service=$MOCKSERVICE_NAME using default mockservice url-path from SoapUI-project=$PROJECT"
        mockservicerunner.sh -Djava.awt.headless=true -p 8091 -m $MOCKSERVICE_NAME $PROJECT <&3 &
    else
        echo "Starting Mock-service=$MOCK_SERVICE_NAME using url-path=$MOCK_SERVICE_PATH from SoapUI-project=$PROJECT"
        mockservicerunner.sh -Djava.awt.headless=true -p 8091 -m $MOCKSERVICE_NAME -a $MOCK_SERVICE_PATH $PROJECT <&3 &
    fi

else
    echo "You can start the Mock-service manually by running"
    echo ">>>  mockservicerunner.sh -Djava.awt.headless=true -p 8091 -m $MOCKSERVICE_NAME $PROJECT"
    gosu soapui "$@" <&3 &
fi

# wait for mocksevicerunner to exit
PID=$!
wait $PID
# prevent another trap while mocksevicerunner is stopping
trap - TERM INT
# wait for stop to complete
wait $PID
