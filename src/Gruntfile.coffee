"use strict"
module.exports = (grunt) ->

  # Load grunt tasks automatically
  require("load-grunt-tasks") grunt

  # Add performance monitoring
  require("time-grunt") grunt
  path = require "path"
  _ = require("underscore")

  grunt.loadTasks 'gruntTasks' # load tasks from the gruntTasks/ directory

  pagerBinary = "pager"
  pagerCommand = "GOMAXPROCS=2 #{pagerBinary}"
  pagerPort = grunt.option('port') || 9027

  ###

  The following base pattern logic is for usemin to use when attempting to process our html
  templates looking for revved versions of files.  The regexes themselves were copied from
  usemin as of version `3.0.0`.  They had to be modified in order to add filter functions that:
    1) Remove $base before searching the filesystem for an appropriate revved file
    2) Add $base back in after the filesystem has been searched.

  This behavior is necessary because the usemin `blockReplacements` functions are run *before*
  the usemin revved file step.  The revved file step, however, normally expects to find
  revved files that are named like the `src=` and `href=` attributes.  In to help usemin find
  the revved files, but still maintain the presence of $base in the final output, we need to do
  this dance.

  ###

  # This regex is used to ensure that usemin's filerev process doesn't attempt process
  # file paths that include "//", which probably indicates its a non-local include
  only_local_references = olr = "(?!.*\/\/)"

  # This regex is used to ensure that usemin's filerev process doesn't attempt process
  # any tag that contains a "no-usemin" attribute
  skip_usemin_processing = sku = "(?!.*no-usemin)"

  link_regex = ///<link#{sku}[^\>]+href=['"]#{olr}([^"']+)["']///gm
  script_regex = ///<script#{sku}.+src=['"]#{olr}([^"']+)["']///gm

  makeBasePattern = (replacement) ->
    [
      [
        link_regex
        'Update the HTML with the new css filenames'
        (m) -> #filterIn
          m.replace("{#{replacement}}", '')
        (m) -> #filterOut
          "{#{replacement}}#{m}"
      ]
      [
        script_regex
        'Update the HTML to reference our concat/min/revved script files'
        (m) -> #filterIn
          m.replace("{#{replacement}}", '')
        (m) -> #filterOut
          "{#{replacement}}#{m}"
      ]
    ]

  base_patterns = makeBasePattern('$base')
  base_obj_patterns = makeBasePattern('$base.url')

  makeCssProcessingBlock = (base) ->
    linkTag = (src, media) ->
      "<link rel=\"stylesheet\" href=\"{#{base}}" + src + "\"" + media + "/>"

    (block) ->
      media = (if block.media then " media=\"" + block.media + "\"" else "")
      newBlock = linkTag(block.dest, media)

      if grunt.makecssmapping?.summary[block.dest]
        newBlock = "<!--[if !IE]> -->#{newBlock}<!-- <![endif]-->"

        includesToInject = _.map grunt.makecssmapping.summary[block.dest], (splitfile) ->
          linkTag(splitfile, media)

        newBlock = "#{newBlock}\n\n<!--[if lte IE 9]>\n#{includesToInject.join('\n')}\n<![endif]-->\n"

      newBlock

  # Define the configuration for all the tasks
  grunt.initConfig

    # Watches files for changes and runs tasks based on the changed files
    watch:
      noop:
        files: "noop"
        tasks: []
      templates:
        files: ["templates/**/*.soy", "../messages/*.po"]
        tasks: "http:reloadtemplates"
        options:
          # Templates are a special case for livereload because we need to give
          # Pager a chance to process the file change and parse the templates

          # Only enable livereload in the "machine running a single pager" case.  The LiveReload Chrome plugin assumes a hardcoded port of 35729, and `watch` will bomb out if a process is alrady listening there.
          livereload: (pagerPort == 9027)
      js:
        files: ["js/**"]
        tasks: ["jshint","copy:js"]
      compass:
        files: ["sass/**"]
        tasks: ["compass:compile_app", "replace:compass_source_maps_app", "autoprefixer:css_app"]
      coffee:
        files: ["coffee/**"]
        tasks: ["coffeelint","coffee:compile", "copy:coffee_sources"]
      favicons:
        files: ["favicon/*.png"]
        tasks: ["favicons"]
      livereload:
        options: {
          # Only enable livereload in the "machine running a single pager" case.  The LiveReload Chrome plugin assumes a hardcoded port of 35729, and `watch` will bomb out if a process is alrady listening there.
          livereload: (pagerPort == 9027)
        },
        files: [
          ".tmp/css/**/*.css"
          ".tmp/js/**/*.js"
        ]

    shell:
      preflight:
        command: "which #{pagerBinary}"
        options:
          async: false

      pager:
        command: "#{pagerCommand} --pagesdir $(dirname $(pwd)) --port=#{pagerPort} --templatedir src/templates --staticdirs 'src/.tmp:src/bower_components:src/sass:desktop:src/.tmp/sprites'"
        options:
          async: true
          execOptions:
            detached: false # Process will be killed when the parent exits

      pager_dist:
        command: "#{pagerCommand} --pagesdir $(dirname $(pwd)) --port=#{pagerPort}"
        options:
          async: true
          execOptions:
            detached: false # Process will be killed when the parent exits

      pager_pull:
        command: "#{pagerCommand} --pagesdir $(dirname $(pwd)) --pull"
        options:
          async: false
          execOptions:
            detached: false # Process will be killed when the parent exits

      fetch_header:
        command: 'casperjs fetchHeaderConfig/fetchHeader.coffee --ssl-protocol=any'
        options:
          async: false

      startupsleep:
        command: 'sleep 2'

      options:
        stdout: true
        stderr: true
        failOnError: true

    open:
      site:
        path: "http://localhost:#{pagerPort}"

    http:
      reloadtemplates:
        options:
          url: "http://localhost:#{pagerPort}/reloadtemplates"

    # Compiles Sass to CSS and generates necessary files if requested
    compass:
      compile_app:
        options:
          sassDir: "sass"
          cssDir: ".tmp/css_staging"
          spriteLoadPath: "sprites"
          generatedImagesDir: ".tmp/sprites/images"
          specify: "**/default.scss"
          relativeAssets: false
          assetCacheBuster: false
          raw: "Sass::Script::Number.precision = 10\n"
          bundleExec: true
          sourcemap: true

      compile_all:
        options:
          sassDir: "sass"
          cssDir: ".tmp/css_staging"
          spriteLoadPath: "sprites"
          generatedImagesDir: ".tmp/sprites/images"
          specify: ["**/vendor.scss", "**/default.scss"]
          relativeAssets: false
          assetCacheBuster: false
          raw: "Sass::Script::Number.precision = 10\n"
          bundleExec: true
          sourcemap: true

    replace:
      compass_source_maps_app:
        src: ['.tmp/css_staging/**/default*.map']
        overwrite: true
        replacements: [
          {
            from: '../../../bower_components'
            to: ''
          },
          {
            from: '../../../sass'
            to: ''
          }
        ]

      compass_source_maps_all:
        src: ['.tmp/css_staging/**/*.map']
        overwrite: true
        replacements: [
          {
            from: '../../../bower_components'
            to: ''
          },
          {
            from: '../../../sass'
            to: ''
          }
        ]

    autoprefixer:
      css_app:
        cwd: '.tmp/css_staging'
        src: '**/default.css'
        dest: '.tmp/css/'
        expand: true
        flatten: false
      css_all:
        cwd: '.tmp/css_staging'
        src: '**/*.css'
        dest: '.tmp/css/'
        expand: true
        flatten: false
      options:
        diff: true
        map: true
        browsers: ['> 1%', 'last 2 versions', 'Firefox > 1', 'Safari > 3', 'Opera 12.1', 'ie 9']

    coffee:
      options:
        sourceMap: true
        sourceRoot: ''
      compile:
        files: [{
          expand: true,
          cwd: 'coffee/',
          src: '{,*/}**/*.coffee',
          dest: '.tmp/js',
          ext: '.js'
        }]

    copy:
      js:
        files: [
          expand: true,
          cwd: 'js/',
          src: '{,*/}**/*.js',
          dest: '.tmp/js',
        ]
      coffee_sources:
        files: [
          expand: true,
          cwd: 'coffee/',
          src: '{,*/}**/*.coffee',
          dest: '.tmp/js',
        ]
      smart_templates_to_process:
        files: [
          expand: true
          flatten: false
          src: [
            "<%- useminPrepare.desktopDirectory.src %>"
            "<%- useminPrepare.desktopSearch.src %>"
            "<%- useminPrepare.desktopLocation.src %>"
          ]
          dest: ".tmp/smart/"
        ]
      smart_templates_processed:
        files: [
          expand: true
          flatten: false
          cwd: ".tmp/smart"
          src: "**"
          dest: "../"
        ]
      dumb_templates:
        files: [
          expand: true
          flatten: false
          src: [
            "templates/**/*.soy"
            "!<%- useminPrepare.desktopDirectory.src %>"
            "!<%- useminPrepare.desktopSearch.src %>"
            "!<%- useminPrepare.desktopLocation.src %>"
          ]
          dest: "../"
        ]
      fonts:
        files: [
          expand: true
          flatten: true
          cwd: "bower_components"
          src: ["**/*.{eot,ttf,otf,woff}"]
          dest: "../desktop/fonts/"
        ]
      sprites:
        files: [
          expand: true
          flatten: false
          cwd: ".tmp/sprites/images"
          src: ["**"]
          dest: '../desktop/images/'
        ]

    csssplit:
      all:
        cwd: '../desktop/'
        expand: true
        src: [
          'css/directory/*.css'
          'css/location/*.css'
          'css/search/*.css'
        ]
        dest: '../desktop/'
      options:
        suppressSinglePage: true

    filerev:
      source:
        files: [
            src: [
                '../desktop/css/directory/*.css'
                '../desktop/css/location/*.css'
                '../desktop/css/search/*.css'
                '../desktop/js/**/*.js'
            ]
          ]

    useminPrepare:

      desktopDirectory:
        src: "templates/directory/head_includes.soy"
        options:
          dest: "../desktop"
          staging: ".tmp/desktop/directory"

      desktopSearch:
        src: "templates/search/head_includes.soy"
        options:
          dest: "../desktop"
          staging: ".tmp/desktop/search"

      desktopLocation:
        src: "templates/location/desktop.soy"
        options:
          dest: "../desktop"
          staging: ".tmp/desktop/location"

    usemin:
      "desktopLocation-html":
        files:
          src: [".tmp/smart/templates/location/desktop.soy"]

        options:
          assetsDirs: ["../desktop"]
          patterns:
            "desktopLocation-html": base_patterns
          blockReplacements:
            css: makeCssProcessingBlock('$base')
            js: (block) ->
              defer = (if block.defer then "defer " else "")
              async = (if block.async then "async " else "")
              "<script " + defer + async + "src=\"{$base}" + block.dest + "\"></script>"

      "desktopDirectory-html":
        files:
          src: [".tmp/smart/templates/directory/head_includes.soy"]

        options:
          assetsDirs: ["../desktop"]
          patterns:
            "desktopDirectory-html": base_obj_patterns
          blockReplacements:
            css: makeCssProcessingBlock('$base.url')
            js: (block) ->
              defer = (if block.defer then "defer " else "")
              async = (if block.async then "async " else "")
              "<script " + defer + async + "src=\"{$base.url}" + block.dest + "\"></script>"

      "desktopSearch-html":
        files:
          src: [".tmp/smart/templates/search/head_includes.soy"]

        options:
          assetsDirs: ["../desktop"]
          patterns:
            "desktopSearch-html": base_obj_patterns
          blockReplacements:
            css: makeCssProcessingBlock('$base.url')
            js: (block) ->
              defer = (if block.defer then "defer " else "")
              async = (if block.async then "async " else "")
              "<script " + defer + async + "src=\"{$base.url}" + block.dest + "\"></script>"

    clean:
      options:
        force: true
      intermediates: ['.tmp', '.sass-cache']
      dist: ['../desktop/css/directory', '../desktop/css/location', '../desktop/css/search', '../desktop/js', '../templates']

    githooks:
      options:
        dest: '../.git/hooks'
        template: 'grunt-hooks-sourcetree-template.hb'
        hashbang: '#!/bin/bash'
        startMarker: '## Running Clean & Build'
        endMarker: '## Clean & Build Finished'
      all:
        'pre-commit' : 'clean build'

    favicons:
      options:
        androidHomescreen: true
        appleTouchPadding: 0
      icons:
        src: 'favicon/favicon.png'
        dest: '../desktop/images'

    coffeelint:
      app: ['Gruntfile.coffee', 'coffee/**/*.coffee']
      options:
        configFile: 'coffeelint.json'

    jshint:
      all: ['js/**/*.js', '!js/lib/**/*.js']
      options:
        'jshintrc': '.jshintrc'

    makecssmapping:
      dist:
        files: [
          cwd: '../desktop'
          src: 'css/**/*_part_*.css'
        ]

    checkDependencies:
      app:
        options:
          onlySpecified: false

  grunt.task.registerTask "clean_preflight", "Checks to make sure that the project is safe to clean.", ->
    dir = "../desktop/css/fonts/**"
    errMsg = "Detected files inside '#{dir}' - clean would remove these files and they won't be regenerated automatically.  Please move them to another location and update any references to them."
    if grunt.file.expand(dir).length > 0
      grunt.fail.warn(errMsg)

  grunt.registerTask "versioning", "component versioning manifest", ->
    myJSON = {}
    myJSON.components = {}
    obj = undefined

    pathToJSON = path.join "templates", "components", "*"

    for dir in grunt.file.expand pathToJSON
      newPath = path.join dir, "*"
      componentName = path.basename dir
      for file in grunt.file.expand newPath
        if path.extname(file) == ".json"
          myJSON.components[componentName] = {}
          obj = grunt.file.readJSON file
          myJSON.components[componentName] = obj

    buffer = new Buffer(JSON.stringify myJSON, null, "  ")
    exportPath = path.join '..', 'desktop', 'manifest.json'
    grunt.file.write exportPath, buffer

  grunt.registerTask "serve", (target) ->

    if target == "dist"
      grunt.log.subhead "<< Distribution Mode >>"
      return grunt.task.run [
        "webserver:dist"
        "shell:startupsleep" # Need to give Pager a sec to wake up before opening the URL
        "open:site"
        "watch:noop" # Poor man's keepalive
      ]

    grunt.task.run [
      "devbuild"
      "webserver"
      "shell:startupsleep" # Need to give Pager a sec to wake up before opening the URL
      "open:site"
      "watch"
    ]

  grunt.registerTask "devbuild", [
    "compass:compile_all"
    "replace:compass_source_maps_all"
    "autoprefixer:css_all"
    "copy:fonts"
    "copy:js"
    "coffeelint"
    "coffee:compile"
    "copy:coffee_sources"
  ]

  grunt.registerTask "build", [
    "checkDependencies"
    "clean_preflight" # TODO(mhupman): Remove once no more sites have fonts within desktop/css or we switch to another system for file-revving
    "clean"
    "devbuild"
    "copy:dumb_templates"
    "copy:sprites"
    "compile_smart_templates"
    "versioning"
  ]

  grunt.registerTask "compile_smart_templates", [
    "copy:smart_templates_to_process"
    "useminPrepare"
    "concat"
    "cssmin"
    "uglify"
    "filerev"
    "csssplit"
    "makecssmapping"
    "usemin"
    "copy:smart_templates_processed"
  ]

  grunt.registerTask "pulldata", [
    "shell:pager_pull"
  ]

  grunt.registerTask "lint", [
    "coffeelint"
    "jshint"
  ]

  grunt.registerTask "webserver", (target) ->

    if target == "dist"
      return grunt.task.run ["shell:preflight", "shell:pager_dist"]

    grunt.task.run [
      "shell:preflight"
      "shell:pager"
    ]

  grunt.registerTask "default", ["serve"]

  grunt.registerMultiTask "makecssmapping", "Generates a mapping of the original CSS files to their split versions created by grunt-cssplit", () ->
    opts = @options()
    grunt.log.debug "Options: #{JSON.stringify(opts)}"

    results = {summary: {}}

    for filePair in @files
      for srcFile in filePair.src
        rawFile = srcFile.replace /_part_[0-9]+/, '' # csssplit
        rawFile = rawFile.replace /\.[a-f0-9]+\./, '.' # filerev

        componentFiles = _.filter filePair.src, (file) ->
          file.indexOf(rawFile.replace('.css', '')) >= 0

        if componentFiles.length > 1 then results.summary[rawFile] = componentFiles

    grunt.log.debug "Results: #{JSON.stringify(results)}"
    grunt[@name] = results