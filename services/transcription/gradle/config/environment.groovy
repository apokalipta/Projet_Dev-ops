desc_project{
    type="app-docker"
    withDocker=true
    withQuarkus=true
    version{
        majorVersion=17
        mediumVersion=1
        minorVersion=0
    }
    artefact{
        group="com.meeting"
        project="meeting"
        projectKey="${group}:${project}"
        dockerImageKey="meeting"
    }
}

pic{
    channel="meeting"
	git{
	    uri="https://scm.service.lixtec.fr/${channel}/${channel}.git"
	}    	
    jenkins{
        uri="https://ci.service.lixtec.fr/view/${channel}"
    }  
    sonar{
        uri="https://quality.service.lixtec.fr"
    }
    artifactory{
		uri="https://repos.service.lixtec.fr/artifactory"
    }
	mavencentral{
		uri="https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/"
	}
}

repository{
	artifactory{
	    release	="technix-release"
	    snapshot ="technix-snapshot"
	    libsRelease="libs-release"
	}
}