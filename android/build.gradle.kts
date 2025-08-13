import org.gradle.api.tasks.Delete
import org.gradle.api.Project
import org.gradle.api.initialization.dsl.ScriptHandler

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory (optional)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Buildscript dependencies
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.3.15") // Kotlin DSL uses double quotes
    }
}

// Plugins block (for Kotlin DSL)
plugins {
    // This only declares plugin; do not apply globally if you will apply in module
    id("com.google.gms.google-services") version "4.3.15" apply false
}
