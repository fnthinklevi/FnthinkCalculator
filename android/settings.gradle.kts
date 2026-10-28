pluginManagement {
    val properties = java.util.Properties()
    listOf("gradle.properties", "local.properties").forEach { name ->
        val propertiesFile = file(name)
        if (propertiesFile.exists()) {
            propertiesFile.inputStream().use { properties.load(it) }
        }
    }
    val flutterSdkPath = properties.getProperty("flutter.sdk")
        ?: error("flutter.sdk not set in local.properties")
    val flutterStorageBaseUrl = properties.getProperty("flutter.storage.base.url")
        ?: "https://storage.flutter-io.cn"
    val useUpstreamFirst = properties.getProperty("useUpstreamFirst")?.toBoolean() ?: false

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

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

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.4.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.21" apply false
}

include(":app")
