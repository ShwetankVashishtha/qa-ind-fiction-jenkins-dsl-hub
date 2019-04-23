def branchesParam = binding.variables.get('BRANCHES')
def branches = branchesParam ? branchesParam.split(' ') : ['AG3-GW_master', 'AG3-GW_patch', 'AG3-GW_release', 'GCS_iOS_dev_x9', 'GCS_iOS_release_x9']

def constants = [

    // generic params
    project: 'BB Work',
    component: 'iOS',
    branches: branches,
    name: 'SeeTest',
    label: 'server-not-defined',
    username: 'niravpatel'

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
            description 'BB Work iOS Automation execution built on Maven with latest code committed on Perforce.'
        }
        
        // Root pom.xml path
        rootPOM("pom.xml")

        // Set goals and option to execute with maven
        goals("-DlabName=onprem -DtestSuite=email/Email_07 -DskipReport=false clean install test")

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
            def username = constants.username
            // Perforce P4 plug in to fetch latest code
            p4('//depot/automation/atf/iOS/dev/...', "${username}") {
                node - >
                node / p4Port('perforce.corp.good.com:3666')
                node / p4Tool('C:/Program Files/Perforce/p4.exe')
                node / exposeP4Passwd('false')
            }
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
                            recipientList('svashishthal@blackberry.com')
                        }
                    }
                }
            }
        }
    }
}
