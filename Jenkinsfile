pipeline {
    agent {
        label 'jslave'
    }

    stages {
        stage('Install and configure puppet agent') {
            steps {
                script {
                    // Job 1: Install and configure puppet agent
                    // Install Puppet Agent
                    sh 'curl -O https://apt.puppetlabs.com/puppet6-release-bionic.deb'
                    sh 'sudo dpkg -i puppet6-release-bionic.deb'
                    sh 'sudo apt-get update'
                    sh 'sudo apt-get install -y puppet-agent'

                    // Configure Puppet Agent
                    sh 'echo "server = puppetmaster.example.com" | sudo tee -a /etc/puppetlabs/puppet/puppet.conf'
                    sh 'sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true'
                }
            }
        }

        stage('Push Ansible configuration to install Docker') {
            steps {
                script {
                    //Job 2: Push Ansible configuration on the test server to install Docker
                    //def testServer = 'ubuntu@ip-172-31-17-187'
                    sh "rm -rf /tmp/ansibletemp ||:"
                    sh "git clone https://github.com/Khaganshu-RK/Edureka-DevOps.git /tmp/ansibletemp"
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@ip-172-31-24-180 'rm -rf ~/installation.yml ||:'"
                    sh "exit"                   
                    //sh "ssh ubuntu@ip-172-31-27-9 'ansible-playbook /tmp/ansibletemp/installation.yml'"
                    sh "scp /tmp/ansibletemp/installation.yml ubuntu@ip-172-31-24-180:~/"
                    //sh "ssh -o StrictHostKeyChecking=no ${testServer} 'ansible-playbook /tmp/ansibletemp/installation.yml'"
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@ip-172-31-24-180 'ansible-playbook -v ~/installation.yml'"
                    sh "exit"
                    //sh "ssh ubuntu@ip-172-31-17-187 'echo hi'"
                    sh "rm -rf /tmp/ansibletemp"
                }
            }
        }

        stage('Build and deploy PHP Docker container') {
            steps {
                // Job 3: Pull PHP website and Dockerfile from Git repo, build, and deploy container
                git branch: 'main', url: 'https://github.com/Khaganshu-RK/Edureka-DevOps.git'
                sh 'docker build -t php-website .'
                sh 'docker run -d -p 80:80 php-website'
            }
        }

        stage('Cleanup on failure') {
            steps {
                // Job 4: Delete the running container on the test server if Job 3 fails
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh 'docker stop $(docker ps -q --filter ancestor=php-website)'
                    sh 'docker rm $(docker ps -aq --filter ancestor=php-website)'
                }
            }
        }
    }
}
