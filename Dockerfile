FROM dcagatay/bamboo-agent-base-dind:8.0.0

ARG UBUNTU_ARCHIVE_PROXY="http://archive.ubuntu.com/ubuntu/"
ARG UBUNTU_SECURITY_PROXY="http://security.ubuntu.com/ubuntu/"
ARG UBUNTU_DOCKER_APT_PROXY="https://download.docker.com/linux/ubuntu"

RUN sed -i "s|http://archive.ubuntu.com/ubuntu/|${UBUNTU_ARCHIVE_PROXY}|g" /etc/apt/sources.list && \
  sed -i "s|http://us.archive.ubuntu.com/ubuntu/|${UBUNTU_ARCHIVE_PROXY}/|g" /etc/apt/sources.list && \
  sed -i "s|http://security.ubuntu.com/ubuntu/|${UBUNTU_SECURITY_PROXY}|g" /etc/apt/sources.list && \
  sed -i "s|https://download.docker.com/linux/ubuntu|${UBUNTU_DOCKER_APT_PROXY}|g" /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        xz-utils

# Install Java 8
ARG JAVA_8_DOWNLOAD_URL="https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u292-b10/OpenJDK8U-jdk_x64_linux_hotspot_8u292b10.tar.gz"
RUN curl -fSL --retry 3 "${JAVA_8_DOWNLOAD_URL}" -o /opt/java.tar.gz && \
  tar -xzf /opt/java.tar.gz -C /opt/ && \
  rm -rf /opt/java.tar.gz && \
  ln -s $(ls -1 /opt | grep jdk8) /opt/java-8-jdk

## Install Maven
ARG MAVEN_DOWNLOAD_URL="https://downloads.apache.org/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz"
RUN curl -fSL --retry 3 "${MAVEN_DOWNLOAD_URL}" -o /opt/maven.tar.gz && \
  tar -xzf /opt/maven.tar.gz -C /opt/ && \
  rm -rf /opt/maven.tar.gz && \
  ln -s $(ls -1 /opt | grep apache-maven-) /opt/maven

ENV M2_HOME "/opt/maven"

## Install Gradle
ARG GRADLE_DOWNLOAD_URL="https://services.gradle.org/distributions/gradle-6.9.1-bin.zip"
RUN curl -fSL --retry 3 "${GRADLE_DOWNLOAD_URL}" -o /opt/gradle.zip && \
  unzip -d /opt /opt/gradle.zip && \
  rm -rf /opt/gradle.zip && \
  ln -s $(ls -1 /opt | grep gradle-) /opt/gradle

ENV GRADLE_HOME "/opt/gradle"

# Install NodeJS
ARG YARN_DOWNLOAD_URL="https://yarnpkg.com/downloads/1.22.5/yarn-v1.22.5.tar.gz"
RUN curl -fSL --retry 3 "${YARN_DOWNLOAD_URL}" -o /opt/yarn.tar.gz && \
  tar -xzf /opt/yarn.tar.gz -C /opt/ && \
  rm -rf /opt/yarn.tar.gz && \
  ln -s $(ls -1 /opt | grep yarn-v) /opt/yarn

ENV YARN_HOME "/opt/yarn"

# Install NodeJS 14
ARG NODE14_DOWNLOAD_URL="https://nodejs.org/dist/v14.17.5/node-v14.17.5-linux-x64.tar.xz"
RUN curl -fSL --retry 3 "${NODE14_DOWNLOAD_URL}" -o /opt/nodejs.tar.xz && \
  tar -xJf /opt/nodejs.tar.xz -C /opt/ && \
  rm -rf /opt/nodejs.tar.xz && \
  ln -s $(ls -1 /opt | grep node-v14) /opt/node-14

ENV NODE_HOME "/opt/node-14"

# Install NodeJS 16
ARG NODE16_DOWNLOAD_URL="https://nodejs.org/dist/v16.7.0/node-v16.7.0-linux-x64.tar.xz"
RUN curl -fSL --retry 3 "${NODE16_DOWNLOAD_URL}" -o /opt/nodejs.tar.xz && \
  tar -xJf /opt/nodejs.tar.xz -C /opt/ && \
  rm -rf /opt/nodejs.tar.xz && \
  ln -s $(ls -1 /opt | grep node-v16) /opt/node-16

RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.git.executable" /usr/bin/git && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 1.8" /opt/java-8-jdk/bin/java && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.mvn3.Maven 3.8" /opt/apache-maven-3.8.1 && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.node.Node.js 14" /opt/node-14/bin/node && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.command.npm 14" /opt/node-14/bin/npm && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.command.npx 14" /opt/node-14/bin/npx && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.command.yarn" /opt/yarn-v1.22.5/bin/yarn && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.node.Node.js 16" /opt/node-16/bin/node && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.command.npm 16" /opt/node-16/bin/npm && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.command.npx 16" /opt/node-16/bin/npx && \
    ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.gradle.Gradle" /opt/gradle-6.9.1

ENV PATH "${M2_HOME}/bin:${GRADLE_HOME}/bin:${NODE_HOME}/bin:${YARN_HOME}/bin:${PATH}"
