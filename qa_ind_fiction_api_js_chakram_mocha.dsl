/**
 * @author shwetankvashishtha
 *
 */

// groovy script approval
def signature = 'new groovy.json.JsonSlurperClassic'
org.jenkinsci.plugins.scriptsecurity.scripts.ScriptApproval.get().approveSignature(signature)

preflightJob()

def preflightJob() {

    return freeStyleJob("qa-ind-fiction-api-js-chakram-mocha") {

        // set up GitHub repo path and credentials
   		scm {
       	 	git {
            	remote {
            		github('ShwetankVashishtha/qa-ind-fiction-api-js-chakram-mocha')
                	credentials('f93b716c-1d56-4503-aa51-1b6b1b3ca387')
                	url('https://github.com/ShwetankVashishtha/qa-ind-fiction-api-js-chakram-mocha.git')
            	}
                extensions {
                    cloneOptions {
                        timeout(10)
                    }
                }
        	}
        }

        steps {
            shell('''
#!/bin/bash
yarn install
yarn test
            ''')
        }
        
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
                report('${JENKINS_HOME}/workspace/qa-ind-fiction-api-js-chakram-mocha/mochawesome-report/') {
                    reportName('HTML Report')
                    reportFiles('mochawesome.html')
                    keepAll()
                    allowMissing()
                    alwaysLinkToLastBuild()
                }
            }
        }
    }
}
