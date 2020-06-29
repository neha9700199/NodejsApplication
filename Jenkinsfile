pipeline{
    agent {
      label 'jenkins-slave'
    }
    environment {
       PROJECT = """${sh(returnStdout: true , script: """echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]' """).trim()}"""
      }
    triggers{
        pollSCM 'H/5 * * * *'
    }
    stages{
        stage('Get the Code'){
            steps{
                echo "checking out the code"
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[credentialsId: 'githubLogin', url: 'https://github.com/neha9700199/NodejsApplication']]])
                    }
        }
            stage('build the code'){
                steps{
                    sh '''sudo apt install curl -y
                    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
                    sudo apt-get install nodejs -y '''
                    sh '''npm ci'''
            }
        }
        stage('start the service'){
            steps{
                sh '''npm start'''
            }
        }
        stage('Build preparations')
        {
            steps
            {
                script 
                {  
                    gitCommitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                    shortCommitHash = gitCommitHash.take(7)
                    VERSION = shortCommitHash
                    currentBuild.displayName = "${BUILD_ID}"
                    IMAGE = "$PROJECT:$VERSION"
                    
                }
            }
        }
        stage('test the service'){
                 environment {
                 EXIT_STATUS = """${sh(returnStatus: true, script: 'npm test')}"""
             }
             stages{
                 stage('build the image'){
                     when{
                         expression{
                             return (EXIT_STATUS == '0')
                         }
                     }
                     steps{
                         script{
                        docker.build('$PROJECT:${BUILD_NUMBER}-`date +%Y-%m-%d`','.')
                     }
                     }
                 }
                 stage('push the image'){
                     steps{
                         script{
                             withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'ecr-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                                      sh ''' aws ecr create-repository --repository-name $PROJECT --region ap-south-1 || true'''
                                               }
                             docker.withRegistry('https://049483755852.dkr.ecr.ap-south-1.amazonaws.com/$PROJECT', 'ecr:ap-south-1:ecr-cred') {
                                       docker.image("$PROJECT:${BUILD_NUMBER}-`date +%Y-%m-%d`").push()
                            }
                        }
                     }
                 }
                 stage('deploy the image'){
                     steps{
                         sshagent(['k8s-cluster-key']) {
                             sh '''sed "s/REPLACE_ME/$PROJECT:${BUILD_NUMBER}-`date +%Y-%m-%d`/g" pod.yml >> new-pod.yml'''
                             sh '''chown -R ubuntu:ubuntu new-pod.yml'''
                             sh "scp -o StrictHostKeyChecking=no *.yml ubuntu@10.0.0.73:/home/ubuntu"
                            script{
                         sh "ssh ubuntu@10.0.0.73 rm pod.yml"
                         sh "ssh ubuntu@10.0.0.73 kubectl apply -f . --kubeconfig admin.config"
                         }
                       }
                     }   
                    }
                 }
             }
             stage('stop the service after testing'){
                        steps{
                        sh '''npm stop'''
                    }
                    }
                    stage('uploading the log files to S3'){
                        steps{
                            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'ecr-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                                      sh ''' aws s3 mb s3://$PROJECT-${BUILD_NUMBER}-`date +%Y-%m-%d` --region ap-south-1 || true
                                          aws s3 cp "coverage/" s3://$PROJECT-${BUILD_NUMBER}-`date +%Y-%m-%d` --region ap-south-1 --recursive
                                          aws s3 cp ".nyc_output/" s3://$PROJECT-${BUILD_NUMBER}-`date +%Y-%m-%d` --region ap-south-1 --recursive
                                          aws s3api put-object-acl --bucket $PROJECT-${BUILD_NUMBER}-`date +%Y-%m-%d` --key index.html --acl public-read --region ap-south-1
                                      '''
                                               }
                        }
                    }
             }
             post {
                 always{
                     cleanWs()
                 }
        success {
            echo 'the Job has been completed successfully!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            mail to: '$DEFAULT_RECIPIENTS',
             subject: "${env.BUILD_URL} - Build # ${env.BUILD_NUMBER}!",
             body: "Check console output at ${env.JOB_NAME} to view the results."
        }
    }
            
         }
    
    



