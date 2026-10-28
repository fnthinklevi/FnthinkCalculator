val localProperties = java.util.Properties()
listOf("gradle.properties", "local.properties").forEach { name ->
    val propertiesFile = file(name)
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { localProperties.load(it) }
    }
}
val flutterStorageBaseUrl = localProperties.getProperty("flutter.storage.base.url")
    ?: "https://storage.flutter-io.cn"
val useUpstreamFirst = localProperties.getProperty("useUpstreamFirst")?.toBoolean() ?: false

allprojects {
    repositories {
        if (useUpstreamFirst) {
            google()
            mavenCentral()
            gradlePluginPortal()
        }
        maven { url = uri("https://maven.aliyun.com/repository/releases") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/snapshots") }
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("$flutterStorageBaseUrl/download.flutter.io") }
        if (!useUpstreamFirst) {
            google()
            mavenCentral()
            gradlePluginPortal()
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
