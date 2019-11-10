tasks.register<Exec>("buildElm") {

    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/main/elm/Main.elm", "--output", jsPath )
}

tasks.register<Exec>("buildElmOptimize") {


    val jsPath = "$projectDir/build/elm.js"

    inputs.dir("$projectDir/src/")
    outputs.file(file(jsPath))

    workingDir = File("$projectDir/src/")
    commandLine = listOf("elm", "make", "$projectDir/src/main/elm/Main.elm", "--optimize", "--output", jsPath )
}


tasks.register<Exec>("build") {
    dependsOn("buildElmOptimize")
    dependsOn("copyResources")
    finalizedBy("deleteElmJs")

    val jsInputPath = "$projectDir/build/elm.js"
    val jsOutputPath = "$projectDir/build/elm.min.js"

    inputs.dir("$projectDir/build/")
    outputs.file(file(jsOutputPath))

    val cl = "uglifyjs ${jsInputPath} --compress 'pure_funcs=\"F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9\",pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output=${jsOutputPath}"

    workingDir = File("$projectDir/src/")
    commandLine("bash", "-c", cl)
}

tasks.register<Copy>("copyResources") {

    description = "Copies resources to build directory."
    group = "properties"

    from(File("$projectDir/src/main/resources/"))
    into(File("$projectDir/build/"))
}

tasks.register<Delete>("clean") {
    delete.add("elm/elm-stuff")
    delete.add("build")
}

tasks.register<Delete>("deleteElmJs") {
    delete.add("build/elm.js")
}