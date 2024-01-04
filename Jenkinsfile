// Jenkinsfile for Techscrum project (by Lawrence)
pipeline {
    agent any

    parameters {
        // Choose an environment to deploy frond-end resources: 'dev', 'uat', or 'prod'.
        choice(choices: ['dev', 'uat', 'prod'], name: 'Environment', description: 'Please choose an environment.')

        // Apply or destroy resources
        choice(choices: ['deploy', 'destroy'], name: 'Operation', description: 'Deploy or destroy resources.')

        // Plan is used for gengrating plan file. Apply is used to deploy or destroy resources.
        choice(choices: ['plan','apply'], name: 'plan_apply', description: 'Plan is used for gengrating plan file. Apply is used to deploy or destroy resources.')
    }
    
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
               credentialsId: 'lawrence-jenkins-credential']
            ]){
              dir('app/techscrum_be'){
                  // Echo terraform vision
                  sh 'terraform --version'

                  // Terraform init
                  sh "terraform init -reconfigure -backend-config=backend_${params.Environment}.conf"

                  // Terraform plan                  
                  if (params.Operation == 'deploy') {
                      sh "terraform plan -var-file=${params.Environment}.tfvars -out=${params.Environment}_${params.Operation}_plan"
                  } else if (params.Operation == 'destroy') {
                      sh "terraform plan -var-file=${params.Environment}.tfvars -out=${params.Environment}_${params.Operation}_plan -destroy"
                  } 

                  // Terraform apply
                  // if choose apply, then execute terraform apply. Else, do not apply.
                  if (params.plan_apply == 'apply') {
                      sh "terraform apply '${params.Environment}_${params.Operation}_plan'"
                    }
                  
                  // Generate a readable pla file
                  sh "terraform show -no-color ${params.Environment}_${params.Operation}_plan > ${params.Environment}_${params.Operation}_plan.txt " 
              }
            }
          }
        }
      }
    }
    
    post {
        success {
            echo "Backend: ${params.Environment}--${params.Operation}--${params.plan_apply} has succeeded."
            emailext(
                to: "lawrence.wenboli@gmail.com",
                subject: "Back-end terraform pipeline (${params.Environment} environment) succeeded.",
                body: 
                    """
                    Pipeline succeeded. \nEnvironment: ${params.Environment}. \nOperation: ${params.Operation}--${params.plan_apply}. \nPlease check the plan file.
                    """,
                attachLog: false,
                attachmentsPattern: "**/${params.Environment}_${params.Operation}_plan.txt"
            )
        }

        failure{
            echo "Backend: ${params.Environment}--${params.Operation}--${params.plan_apply} has failed."
            emailext(
                to: "lawrence.wenboli@gmail.com",
                subject: "Back-end terraform pipeline (${params.Environment} environment) failed.",
                body: 
                    """
                    Pipeline failed.\nEnvironment: ${params.Environment}. \nOperation: ${params.Operation}--${params.plan_apply}. \nPlease check logfile for more details.
                    """,
                attachLog: true
            )
        }
    }
}
