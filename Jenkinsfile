pipeline {
  agent any

  stages {
    stage('Cloning the project from GitHub'){
      steps {
        git branch: 'main',
        url: 'https://github.com/mrasuli/mongo_spartan.git'
      }
    }
  }
}
