tasks.register<Exec>("build") {
    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/main/elm/Main.elm", "--output", jsPath )
}

tasks.register<Copy>("copyResources") {

    description = "Copies resources to build directory."
    group = "properties"

    from(File("$projectDir/src/main/resources/"))
    into(File("$projectDir/build/"))
}

tasks.register<Delete>("clean") {
    delete.add("elm/elm-stuff/0.19.0")
    delete.add("elm/elm-stuff/generated-code")
    delete.add("build")
}