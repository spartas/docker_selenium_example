#!/usr/bin/env bash
sudo yum -y update
sudo yum -y install docker
sudo service docker start

$(aws ecr get-login --region us-east-2 --no-include-email)
docker pull {ECR_URL}
docker tag {ECR_URL}:latest {CONTAINER_IMG_NAME}:latest
#docker run -d --restart on-failure {CONTAINER_IMG_NAME}

cat << SLAUNCH > /etc/init.d/selenium_launcher
#!/bin/bash
# chkconfig: 345 97 80
# description: Launcher for running the selenium docker container

# Source function library.
. /etc/init.d/functions

start() {
    # code to start app comes here 
    # example: daemon program_name &
  docker run -d --restart on-failure {CONTAINER_IMG_NAME}
}

case "\$1" in 
    start)
       start
       ;;
    *)
       echo "Usage: \$0 {start}"
esac

exit 0 
SLAUNCH

chmod +x /etc/init.d/selenium_launcher
chkconfig --add /etc/init.d/selenium_launcher
chkconfig selenium_launcher --levels 345 on

