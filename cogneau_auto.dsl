/**
 * @author shwetankvashishtha
 *
 */

// groovy script approval
def signature = 'new groovy.json.JsonSlurperClassic'
org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval.get().approveSignature(signature)

preflightJob()

def preflightJob() {

    return mavenJob("cogneau-auto") {

        // set up GitHub repo path and credentials
   		scm {
       	 	git {
            	remote {
            		github('ShwetankVashishtha/cogneau-auto')
                	credentials('f28ea095-1e6c-4db3-9caf-df625e75f9b9')
                	url('https://github.com/ShwetankVashishtha/cogneau-auto.git')
            	}
                extensions {
                    cloneOptions {
                        timeout(10)
                    }
                }
        	}
        }

        //define maven goals
        goals('clean install test sonar:sonar -Dsonar.host.url=http://localhost:9000 -Dsonar.login=20ee5864239873ffbd75f8c0dff93298db4fc4e7')

        // Manages how long to keep records of the builds.
        logRotator {
            // If specified, only up to this number of builds have their artifacts retained.
            artifactNumToKeep(10)
            // If specified, only up to this number of build records are kept.
            numToKeep(10)
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
        }

        // Allows to publish archive artifacts
        publishers {
            publishHtml {
                report('${JENKINS_HOME}/workspace/cogneau-auto/test-output/html') {
                    reportName('HTML Report')
                    reportFiles('index.html')
                    keepAll()
                    allowMissing()
                    alwaysLinkToLastBuild()
                }
            }
        }
    }
}
