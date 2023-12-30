echo "Configure Jenkins"
mkdir -p /var/lib/jenkins/init.groovy.d
mv /groovy_scripts/*.groovy /var/lib/jenkins/init.groovy.d/
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
mv /tmp/config/jenkins /etc/sysconfig/jenkins
chmod +x /tmp/config/install-plugins.sh
mkdir -p /var/lib/jenkins/plugins
chown -R jenkins:jenkins /var/lib/jenkins/plugins
bash /tmp/config/install-plugins.sh
service jenkins start