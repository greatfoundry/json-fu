# Based on jashkenas' Cakefile for the wonderful CoffeeScript
fs            = require 'fs'
path          = require 'path'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors.
bold  = '\033[0;1m'
red   = '\033[0;31m'
green = '\033[0;32m'
reset = '\033[0m'

# Built file header.
header = """
  /**
   * CoffeeScript Compiler v0.1.0
   * http://github.com/greatfoudry/json-fu
   *
   * Copyright 2011, GreatFoundry Software, Inc.
   * Released under the MIT License
   */
"""

sources = [
  'src/json-fu.coffee'
]

# Log a message with a color.
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

task 'build', 'build json-fu from source', ->
  files = fs.readdirSync 'src'
  files = ('src/' + file for file in files when file.match(/\.coffee$/))
  exec("coffee -c -o lib #{files}", (err, stdout, stderr) ->
    if err then console.log stderr.trim() else log 'done', green
  )

task 'doc:site', 'watch and continually rebuild the documentation for the website', ->
  exec 'rake doc', (err) ->
    throw err if err


task 'doc:source', 'rebuild the internal documentation', ->
  exec 'docco src/*.coffee && cp -rf docs documentation && rm -r docs', (err) ->
    throw err if err


task 'doc:underscore', 'rebuild the Underscore.coffee documentation page', ->
  exec 'docco examples/underscore.coffee && cp -rf docs documentation && rm -r docs', (err) ->
    throw err if err

  console.log "total  #{ fmt total }"

task 'loc', 'count the lines of source code in the CoffeeScript compiler', ->
  exec "cat #{ sources.join(' ') } | grep -v '^\\( *#\\|\\s*$\\)' | wc -l | tr -s ' '", (err, stdout) ->
    console.log stdout.trim()


# Run the CoffeeScript test suite.
runTests = () ->
  startTime   = Date.now()
  currentFile = null
  passedTests = 0
  failures    = []

  # make "global" reference available to tests
  global.global = global

  # Mix in the assert module globally, to make it available for tests.
  addGlobal = (name, func) ->
    global[name] = ->
      passedTests += 1
      func arguments...

  addGlobal name, func for name, func of require 'assert'

  # Convenience aliases.
  global.eq = global.strictEqual
  global.jsonfu = require './lib/json-fu'
  global.CoffeeScript = CoffeeScript

  # Our test helper function for delimiting different test cases.
  global.test = (description, fn) ->
    try
      fn.test = {description, currentFile}
      fn.call(fn)
    catch e
      e.description = description if description?
      e.source      = fn.toString() if fn.toString?
      failures.push file: currentFile, error: e

  # A recursive functional equivalence helper; uses egal for testing equivalence.
  # See http://wiki.ecmascript.org/doku.php?id=harmony:egal
  arrayEqual = (a, b) ->
    if a is b
      # 0 isnt -0
      a isnt 0 or 1/a is 1/b
    else if a instanceof Array and b instanceof Array
      return no unless a.length is b.length
      return no for el, idx in a when not arrayEqual el, b[idx]
      yes
    else
      # NaN is NaN
      a isnt a and b isnt b

  global.arrayEq = (a, b, msg) -> ok arrayEqual(a,b), msg

  # When all the tests have run, collect and print errors.
  # If a stacktrace is available, output the compiled function source.
  process.on 'exit', ->
    time = ((Date.now() - startTime) / 1000).toFixed(2)
    message = "passed #{passedTests} tests in #{time} seconds#{reset}"
    return log(message, green) unless failures.length
    log "failed #{failures.length} and #{message}", red
    for fail in failures
      {error, file}      = fail
      jsFile             = file.replace(/\.coffee$/,'.js')
      match              = error.stack?.match(new RegExp(fail.file+":(\\d+):(\\d+)"))
      match              = error.stack?.match(/on line (\d+):/) unless match
      [match, line, col] = match if match
      log "\n  #{error.toString()}", red
      log "  #{error.description}", red if error.description
      log "  #{jsFile}: line #{line or 'unknown'}, column #{col or 'unknown'}", red
      console.log "  #{error.source}" if error.source

  # Run every test in the `test` folder, recording failures.
  fs.readdir 'test', (err, files) ->
    files.forEach (file) ->
      return unless file.match(/\.coffee$/i)
      filename = path.join 'test', file
      fs.readFile filename, (err, code) ->
        currentFile = filename
        try
          CoffeeScript.run code.toString(), {filename}
        catch e
          failures.push file: currentFile, error: e


task 'test', 'run the json-fu test suite', ->
  runTests CoffeeScript


task 'test:browser', 'run the test suite against the merged browser script', ->
  source = fs.readFileSync 'extras/coffee-script.js', 'utf-8'
  result = {}
  global.testingBrowser = yes
  (-> eval source).call result
  runTests result.CoffeeScript
