allprojects {
    repositories {
        google()
        mavenCentral()
        // Dépôt Maven pour ffmpeg-kit
        maven {
            url = uri("https://github.com/arthenica/ffmpeg-kit/releases/download/v6.0/")
        }
        maven {
            url = uri("https://jitpack.io")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
