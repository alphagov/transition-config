#!/usr/bin/env groovy

REPOSITORY = 'transition-config'

node {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  try {
    stage('Checkout') {
      checkout scm
    }

    stage('Clean') {
      govuk.cleanupGit()
      govuk.mergeMasterBranch()
    }

    stage('Bundle') {
      govuk.bundleApp()
    }

    stage('Tests') {
      govuk.runTests('test validate:all')
    }

    stage('Push release tag') {
      govuk.pushTag(REPOSITORY, BRANCH_NAME, 'release_' + BUILD_NUMBER)
    }

    stage('Deploy to Integration') {
      // Deploy on Integration (only master)
      govuk.deployIntegration(REPOSITORY, BRANCH_NAME, 'release', 'deploy')
    }

  } catch (e) {
    currentBuild.result = 'FAILED'
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    throw e
  }
}
