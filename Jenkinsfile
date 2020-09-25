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
    def c = """#!c:\\tools\\cygwin\\bin\\bash --login
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
		checkout scm
	}


	stage("Build-${platform}"){
		if(isWindows()){
			runInCygwin "cmake ."
      	  	runInCygwin "make install"
g      	  	runInCygwin "make package"
    	}else{
			cmakeBuild generator: "Unix Makefiles", sourceDir: ".", installation: "InSearchPath"
			shell "make install"
			shell "make prepare-tests test"
			shell "make package"
    	}
		
		junit allowEmptyResults: true, testResults: "build/test/*.xml"
		
		stash excludes: '_CPack_Packages', includes: 'build/packages/*', name: "packages-${platform}"
		archiveArtifacts artifacts: 'build/packages/*', excludes: '_CPack_Packages'
	}
}

def upload(platform, dir, zipPlatformName) {

	unstash name: "packages-${platform}"

	def expandedFileName = sh(returnStdout: true, script: "ls build/packages/PThreadedFFI*${zipPlatformName}*.zip").trim()

	sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
		sh "scp -o StrictHostKeyChecking=no \
		${expandedFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64/${dir}/third-party"
	}
}

def isPullRequest() {
  return env.CHANGE_ID != null
}

def uploadPackages(){
	node('unix'){
		stage('Upload'){
			if (isPullRequest()) {
				//Only upload files if not in a PR (i.e., CHANGE_ID not empty)
				echo "[DO NO UPLOAD] In PR " + (env.CHANGE_ID?.trim())
				return;
			}
			
			if(env.TAG_NAME ==~ /v\d+\.\d+\.\d+.*/){
				upload('osx', 'mac', 'osx64')
				upload('unix', 'linux', 'linux64')
				upload('windows', 'win', 'win64')
				return;
			}
			
			echo "[DO NO UPLOAD] It is not a tag with the form v1.0.0"
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
