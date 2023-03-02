ARG JENKINS_VERSION
FROM jenkins/jenkins:${JENKINS_VERSION}

USER jenkins

COPY jenkins.yaml ${JENKINS_HOME}/jenkins.yaml

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -p $(while IFS=$' \t\r\n' read -r line; do echo -n "$line "; done < /usr/share/jenkins/ref/plugins.txt)
