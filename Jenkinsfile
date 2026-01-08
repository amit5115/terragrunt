pipeline {
  agent any

  parameters {
    choice(
      name: 'TG_ACTION',
      choices: ['plan', 'apply', 'destroy'],
      description: 'Terragrunt action'
    )

    choice(
      name: 'ENV',
      choices: ['dev'],
      description: 'Environment'
    )
  }

  environment {
    GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-sa-key')
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/amit5115/terragrunt.git'
      }
    }

    stage('Terragrunt Init') {
      steps {
          sh 'terragrunt run-all init'
      }
    }

    stage('Terragrunt Plan') {
      when {
        expression { params.TG_ACTION == 'plan' }
      }
      steps {
          sh 'terragrunt run-all plan'
        }
    }

    stage('Terragrunt Apply') {
      when {
        expression { params.TG_ACTION == 'apply' }
      }
      steps {
          sh 'terragrunt run-all apply --terragrunt-non-interactive'
        }
    }

    stage('Terragrunt Destroy') {
      when {
        expression { params.TG_ACTION == 'destroy' }
      }
      steps {
          sh 'terragrunt run-all destroy --terragrunt-non-interactive'
        }
      
    }
  }
}
