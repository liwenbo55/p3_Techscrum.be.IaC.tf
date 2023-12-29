pipeline {
    agent any
    
    // parameters {
    //     string(name: 'AWS_CREDENTIAL_ID', defaultValue: 'markwang access', description: 'The ID of the AWS credentials to use')
    //     string(name: 'GIT_BRANCH', defaultValue: 'feature/devops-mark2', description: 'The Git branch to build and deploy')
    // }
    
    stages {
      stage('Check out code'){
        steps{
          git branch:'main', url:'https://github.com/liwenbo55/p3_Techscrum.tf.be.git'                
        }
      }

      stage('IaC') {
        steps{
          script {
            withCredentials([
              [$class: 'AmazonWebServicesCredentialsBinding', 
               credentialsId: 'lawrence-jenkins-credential', 
               accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
               secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
            ]){
              dir('app/techscrum_be'){
                  sh 'terraform --version'
                  sh 'terraform init -reconfigure -backend-config=backend_uat.conf -input=false'
                  sh 'terraform plan -var-file="uat.tfvars" -out=UAT_PLAN -input=false'
                  sh 'terraform apply "UAT_PLAN"'
              }
            }
          }
        }
      }
    }
}
