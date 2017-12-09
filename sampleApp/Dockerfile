FROM amazonlinux:2017.09

# Install Java
RUN \
    yum update -y \
    && yum -y install java-1.8.0-openjdk-devel

# deploy
ADD ./build/libs/sample-1.0-SNAPSHOT.jar /app/demo-1.0.jar
CMD java -jar /app/demo-1.0.jar