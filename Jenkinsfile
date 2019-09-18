def isWindows(){
  //If NODE_LABELS environment variable is null, we assume we are on master unix machine
  if (env.NODE_LABELS == null) {
    return false
  }
    return env.NODE_LABELS.toLowerCase().contains('windows')
}

def shell(params){
    if(isWindows()) bat(params) 
    else sh(params)
}

def runInCygwin(command){
    def c = """#!c:\\cygwin64\\bin\\bash --login
    cd `cygpath \"$WORKSPACE\"`
    set -ex
    ${command}
    """
    
    echo("Executing: ${c}")
    withEnv(["PHARO_CI_TESTING_ENVIRONMENT=true"]) {    
      return sh(c)
    }
}


def runBuild(platform){
	cleanWs()
	

    stage("Checkout-${platform}"){
      dir('repository') {
          checkout scm
      }
    }


	stage("Build-${platform}"){
		if(isWindows()){
			runInCygwin "cmake ."
      	  	runInCygwin "make install"
      	  	runInCygwin "make test"
      	  	runInCygwin "make package"
    	}else{
			cmakeBuild generator: "Unix Makefiles", sourceDir: ".", installation: "InSearchPath"
			shell "make install"
			shell "make test"
			shell "make package"
    	}
		stash excludes: '_CPack_Packages', includes: 'build/build/packages/*', name: "packages-${platform}-${configuration}"
		archiveArtifacts artifacts: 'build/build/packages/*', excludes: '_CPack_Packages'
	}
}

def upload(platform, configuration, vmDir) {

	unstash name: "packages-${platform}-${configuration}"

	def expandedBinaryFileName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${vmDir}64-bin.zip").trim()
	def expandedHeadersFileName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${vmDir}64-include.zip").trim()

	sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/${vmDir}"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedHeadersFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/${vmDir}/include"

		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/${vmDir}/latest.zip"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedHeadersFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/${vmDir}/include/latest.zip"
	}
}

def uploadPackages(){
	node('unix'){
		stage('Upload'){
//			if (isPullRequest()) {
				//Only upload files if not in a PR (i.e., CHANGE_ID not empty)
//				echo "[DO NO UPLOAD] In PR " + (env.CHANGE_ID?.trim())
//				return;
//			}
			
//			if(env.BRANCH_NAME != 'headless'){
//				echo "[DO NO UPLOAD] In branch different that 'headless': ${env.BRANCH_NAME}";
//				return;
//			}
			
//			upload('osx', "CoInterpreterWithQueueFFI", 'mac')
//			upload('unix', "CoInterpreterWithQueueFFI",'linux')
//			upload('windows', "CoInterpreterWithQueueFFI", 'win')
		}
	}
}

try{
    properties([disableConcurrentBuilds()])

    def platforms = ['unix', 'osx', 'windows']
	def builders = [:]
	def tests = [:]

	for (platf in platforms) {
        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        def platform = platf
		
		builders[platform] = {
			node(platform){
				timeout(30){
					runBuild(platform)
				}
			}
		}		
	}
  
	parallel builders
	
	uploadPackages()

} catch (e) {
  throw e
}
