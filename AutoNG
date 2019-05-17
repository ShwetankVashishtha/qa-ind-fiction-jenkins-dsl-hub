def branchesParam = binding.variables.get('BRANCHES')
def branches = branchesParam ? branchesParam.split(' ') : ['qa', 'dev', 'load', 'pa']

def constants = [

    // generic params
    project: 'QA Fiction',
    component: 'iOS',
    branches: branches,
    name: 'Test Automation',
    label: 'server-not-defined',
    username: ''

]

def friendlyProject = constants.project.capitalize()
def friendlyComponent = constants.component.capitalize()
folder(constants.component) {
    displayName("${friendlyProject} ${friendlyComponent}")
}

for (branch in constants.branches) {
    postflightJob(constants, branch)
}

def postflightJob(constants, branch) {
    def friendlyBranch = branch.capitalize()
    def friendlyLabel = constants.name.capitalize()

    return mavenJob("${constants.component}/${branch}-${constants.name}") {
        // Sets a display name for the project.
        displayName("${friendlyLabel} ${friendlyBranch}").with {
            description ''
        }
        
        // Root pom.xml path
        rootPOM("pom.xml")

        // Set goals and option to execute with maven
        goals("-DlabName=onprem -DskipReport=false clean install test")

        // Allows Jenkins to schedule and execute multiple builds concurrently.
        concurrentBuild()
        // Label which specifies which nodes this job can run on.
        label(constants.label)

        // Manages how long to keep records of the builds.
        logRotator {
            // If specified, only up to this number of builds have their artifacts retained.
            artifactNumToKeep(100)
            // If specified, only up to this number of build records are kept.
            numToKeep(100)
        }

        // Block any upstream and downstream projects while building current project
        configure {
            def aNode = it
            def anotherNode = aNode / 'blockBuildWhenDownstreamBuilding'
            anotherNode.setValue('true')
                (it / 'blockBuildWhenUpstreamBuilding').setValue('true')
        }

        // Adds pre/post actions to the job.
        wrappers {
            preBuildCleanup()
            colorizeOutput()
            timestamps()
            buildName('#${dev}')

        }

        scm {

        }

        // Adds build steps to the jobs.

        // Allows to publish archive artifacts
        publishers {
            archiveArtifacts('target/**/*')
            archiveTestNG('**/target/*.xml') {
                escapeTestDescription()
                escapeExceptionMessages(false)
                showFailedBuildsInTrendGraph()
                markBuildAsUnstableOnSkippedTests(true)
                markBuildAsFailureOnFailedConfiguration(true)
            }
            extendedEmail {
                defaultSubject('$DEFAULT_SUBJECT')
                defaultContent('$DEFAULT_CONTENT')
                contentType('text/html')
                triggers {
                    always {
                        subject('$PROJECT_DEFAULT_SUBJECT')
                        content('$PROJECT_DEFAULT_CONTENT')
                        contentType('text/html')
                        sendTo {
                            recipientList('vashishthashwetank@gmail.com')
                        }
                    }
                }
            }
        }
    }
}
