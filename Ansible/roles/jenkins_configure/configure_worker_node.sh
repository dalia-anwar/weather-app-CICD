#!/bin/bash

JENKINS_MASTER_URL="http://jenkins-master-url/"
JENKINS_USER="<your-jenkins-user>"
JENKINS_PASSWORD="<your-jenkins-password>"
NODE_NAME="<node-name>"
NODE_EXECUTORS=2  # Number of executors for the node

# Step 1: Create a new node using Jenkins CLI
java -jar jenkins-cli.jar -s $JENKINS_MASTER_URL -auth $JENKINS_USER:$JENKINS_PASSWORD create-node $NODE_NAME << EOF
<slave>
  <name>$NODE_NAME</name>
  <description>Automated slave node</description>
  <remoteFS>/var/jenkins</remoteFS>
  <numExecutors>$NODE_EXECUTORS</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy\$Always"/>
  <launcher class="hudson.slaves.JNLPLauncher"/>
  <label></label>
  <nodeProperties/>
</slave>
EOF

# Step 2: Generate an API token for the slave node
API_TOKEN=$(java -jar jenkins-cli.jar -s $JENKINS_MASTER_URL -auth $JENKINS_USER:$JENKINS_PASSWORD -webSocket get-node $NODE_NAME | jq -r .actions[0].causes[0].token)

echo "Jenkins Slave Node '$NODE_NAME' created successfully."
echo "API Token for Node '$NODE_NAME': $API_TOKEN"
