# JSONFu - Kick-ass JSON utilities for JavaScript

# smartSplit String Mixin
# -----------------------
#
# Splits the string by the (single) given separator char.  Does a reasonable job
# of ignoring commas inside quotes.  It isn't perfect but works adequately for most
# balanced or almost-balanced strings
String::smartSplit = (separator) ->
    inSingleQuote = no
    inDoubleQuote = no
    inQuote = () -> inSingleQuote || inDoubleQuote
    parts = []
    splitIdx = 0
    curIdx = 0
    for char in this
        inDoubleQuote = !inDoubleQuote if char == '"' and not inSingleQuote
        inSingleQuote = !inSingleQuote if char == '\'' and not inDoubleQuote
        if char == separator and not inQuote()
            parts.push this.substr(splitIdx, curIdx - splitIdx)
            splitIdx = curIdx
            splitIdx++

        curIdx++
    
    parts.push this.substr(splitIdx, curIdx - splitIdx) if splitIdx < curIdx

    parts

# JSONPath
# --------

# A JSONPath is an n-dimensional vector into a JSONSpace
#
# Paths are components that navigate into a space. Given a path vector:
#    <p0, p1, ... pn>
#
# The element returned is that obtained by starting at the root of the space, 
#    - Moving to the p0th object inside the root object
#    - Descending into that object and moving to the p1st object
#    - Descending into that object and moving to the p2nd object
#    - ...
#    - Descending into that object and moving to the pnth object
#    - Returning that object
#
# Paths that are outside the boundary of the space return undefined
#
# Observe that, in Javascript, objects are unordered sets of key/value pairs.
# The spec does not guarantee that these will be returned or represented in any
# particulary orders.  Because of this, the pn's are only numbers when referencing
# a scalar object or a position in an array.  For objects, the pn's will be the keys
# of the object.
#
# The following are examples of JSONPaths:
#    (0)
#    (0, 0)
#     (0, 3, 4, 2, 8, 0)
#    ("foo")
#    (0, 3, "foo", 3, "bar", 7)
class JSONPath
    @className = "JSONPath"
    
    @fromString = (string) ->
        path = new JSONPath
        return path if not string?
        string = string.replace "(", ""
        string = string.replace ")", ""
        args = string.smartSplit(',')
        path.pathComponents.push arg for arg in args
        path

    constructor: (pathComponents...) ->
        @pathComponents = []
        @pathComponents.push pathComponent for pathComponent in pathComponents

    length: () -> @pathComponents.length

    leadingComponent: () -> @pathComponents[0]

    lastComponent: () -> @pathComponents[@pathComponents.length - 1]

    pathByRemovingComponent: () ->
        first = @pathComponents.slice(0, @pathComponents.length - 1)
        new JSONPath(first...)

    pathByAppendingComponent: (component) ->
        new JSONPath(@pathComponents..., component)

    pathWithoutLeadingComponent: () ->
        rest = @pathComponents.slice 1
        new JSONPath(rest...)

    toString: () ->
        "(#{component for component in @pathComponents})"

    toJSON: () ->
        toString()

# JSONNavigator
# -------------
#
# JSONNavigators return one more more nodes in the object graph given various queries
class JSONNavigator
    @className = "JSONNavigator"

    constructor: (@root = null) ->
    
    # Given a JSONPath, returns the object at that path position.  The path is relative to 
    # this space
    objectAtPath: (path) ->
        thisComponent = path.leadingComponent()
        restOfPath = path.pathWithoutLeadingComponent()

        if not thisComponent? and restOfPath.length > 0
            return undefined
        
        if not thisComponent?
            return @root
        
        child = @root[thisComponent]
        if not child?
            return undefined
        
        childNav = new JSONNavigator(child)
        return childNav.objectAtPath restOfPath

# JSONSpace
# ---------
#
# A JSONSpace is a code representation of an eventual JSON encoding of an object or part of an object.
#
#    Each value in an array is a JSONSpace
# Each value in a key/value object property is a JSONSpace
# The root object, array, or value is a JSONSpace
#   
# Representing an object graph as a graph of JSONSpaces before stringifying it makes it easier
# to do advanced operations like recording references to other parts of the object graph
class JSONSpace
    @className = "JSONSpace"

    constructor: (@parent = null, @prev = null, @next = null) ->
        @children = null        # PLEASE don't add or remove stuff to here manually. Pretty-please?
        @value = undefined      # Not Null, undefined!  I did that on purpose.  But I guess we're arguing semantics

    addChild: (child, key = null) ->
        if not @children? and not key?
            # Awwww, my first child!  Too bad I'm a single parent :-(
            @children = []
        else if not @children and key?
            @children = {}

        # You fed your brussel sprouts to the dog.... go to your room!!
        child.parent = this
        child.next = null
        child.prev = null
        if @children.length > 0
            brother = @children[@children.length - 1]

            # Yeah, I know you don't want to share your room with the new kid...
            # tough.  I hear you can separate the room using duct tape.
            child.prev = brother
            brother.next = child

        # Well I guess there's no turning back now... gotta keep the kid
        if key?
            @children[key] = child
        else
            @children.push child
    
    toJSON: () ->
        if not @children
            if @value.toJSON?
                @value.toJSON()
            else
                @value
        else if @children instanceof Array
            child for child in @children
        else if typeof @children == 'object'
            hash = {}
            hash[key] = value for key, value of @children
            hash

# JSONSigil
# ---------
#
# A JSONSigil is a special value in the JSON representation that serves as a directive
# or provides more information.  For example, the MoreSigil is a way to specify that
# the object was deeper than what is currently represented
class JSONSigil
    @className = "JSONSigil"
    @prefix = "__@JSON_"                # This should never show up in the wild
                                        # (and 640K should be enough for everyone)

    @factory = {}
    @sigilFromName = (name) ->
        args = ""
        argPos = name.indexOf("(")
        args = name.substr(argPos+1, name.length - argPos - 2) if argPos != -1
        name = name.substr(0, argPos) if argPos != -1
        cls = @factory[name]
        if cls?
            sigil = new cls()
            sigil.parseArgs(args.smartSplit(',')) if args != ""
            sigil
        else
            null
    
    constructor: (@name = "") ->
        # Did you know that the word "sigil" has been around long before it was
        # stolen for computer science use?  I didn't.  But Wikipedia enlightened me...
        # http://en.wikipedia.org/wiki/Sigil_(magic))
        JSONSigil.factory[@name] = this.constructor
    
    # Takes string args (without the parenthesis) and does the appropriate thing for them...
    # ...whatever that is for the particular sigil
    parseArgs: (args) ->
    
    # Retrieves the value of this Sigil according to the type
    value: () ->

    toString: () -> "#{JSONSigil.prefix}#{@name}"
    
    toJSON: () -> @toString()

# NullSigil
# ---------
#
# The NullSigil signifies that the original model had a defined key for this property but
# no value.  Useful because it's nice to reconstruct objects faithfully accross the wire
# even when there were empty properties
class NullSigil extends JSONSigil
    @className = "NullSigil"

    constructor: () ->
        super "null"

    value: () -> null

# UndefinedSigil
# --------------
#
# The UndefinedSigil is like the NullSigil but it capture's undefined rather than null.  The 
# distinction is made because there's often a semantic difference that needs to be represented
class UndefinedSigil extends JSONSigil
    @className = "UndefinedSigil"
    
    constructor: () ->
        super "undefined"

    value: () -> undefined

# MoreSigil
# ---------
#
# The MoreSigil signifies that the original model had deeper structure than what is represented here.
# It has an optional parameter that specifies how many immediate properties were not serialized.
#
# For example, if there was an array with 20 elements, the Sigil would be __@JSON_more(20)
# 
# Very useful as hints to clients that want to know more about the deeper structure without actually
# retrieving it
class MoreSigil extends JSONSigil
    @className = "MoreSigil"

    constructor: (@count = null) ->
        super "more"

    parseArgs: (args) ->
        if not args? or args?.length == 0
            @count = 0
        else
            @count = parseInt args[0]

    toString: () ->
        if @count?
            "#{super}(#{@count})"
        else
            super

# RefSigil
# --------
#
# A RefSigil signifies a reference to another part of the JSONSpace.  The path 
# parameter is a JSONPath and is relative to the root of the space
class RefSigil extends JSONSigil
    @className = "RefSigil"
    
    @isRefSigil = (name) ->
        name.lastIndexOf("#{JSONSigil.prefix}ref", 0) == 0

    constructor: (@path = new JSONPath) ->
        super "ref"
        
    parseArgs: (args) ->
        if not args? or args?.length == 0
            @path = new JSONPath
        else
            components = (pathComponent for pathComponent in args)
            @path = new JSONPath(components...)

    value: (root) ->
        return undefined if not root?
        
        nav = new JSONNavigator(root)
        nav.objectAtPath @path

    toString: () ->
        "#{super}#{@path.toString()}"

# FunctionSigil
# -------------
# 
# A FunctionSigil specifies that the original object had a function here
# 
# TODO: We should represent the function if possible and desired
class FunctionSigil extends JSONSigil
    @className = "FunctionSigil"

    constructor: () ->
        super "function"

    value: () -> () ->

# Internal Methods
# ----------------

# This takes an object and turns it into a jsonSpace, but that was probably obvious
toJsonSpace = (object, parentSpace, path, depthLimit, sigils) ->
    space = new JSONSpace(parentSpace)
     
    if object instanceof JSONSpace
        # I'm sure there's a use case for doing that (or someone just got through reading GEB), 
        # but since it makes my head spin I'm just not going to try.
        # kthxbye
        throw "object is already a JSONSpace"
    
    else if depthLimit? and path.length() > depthLimit
        # That's, like, WAY deep man
        return null if not sigils
        space.value = new MoreSigil

    else if object == undefined
        return null if not sigils
        space.value = new UndefinedSigil

    else if object == null
        return null if not sigils
        space.value = new NullSigil
    
    else if typeof object == 'function'
        return null if not sigils
        space.value = new FunctionSigil
   
    objectCache ?= []
    
    # FIXME: Find a faster way to do this
    objectPath = null
    for testObject in objectCache when sigils
        if testObject.ref == object
            objectPath = testObject.path
            break

    if objectPath? and sigils
        # We've already encountered this object elsewhere in the object model
        space.value = new RefSigil(objectPath)
   
    # End of special cases
    if space.value?
        return space if sigils
        return null
    
    switch typeof object
        when 'string'
            space.value = "#{object}"
        when 'number'
            space.value = object
        when 'boolean'
            space.value = object
        when 'object'
            space.value = object
            if object instanceof Array
                if depthLimit? and path.length() + 1 > depthLimit
                    return null if not sigils

                    # Recursing here would break the depth limit, so we'll just
                    # specify there's more here
                    count = 0
                    count++ for value in object
                    space.value = new MoreSigil(count)
                else
                    objectCache.push {ref: object, path: path}
                
                    space.children = []
                    i = 0
                    for child in object
                        subspace = toJsonSpace child, space, path.pathByAppendingComponent(i), depthLimit, sigils
                        space.addChild(subspace) if subspace?
                        i++
                

            else    # Must be a normal object
                if depthLimit? and path.length() + 1 > depthLimit
                    return null if not sigils

                    # Recursing here would break the depth limit, so we'll just
                    # specify there's more here
                    count = 0
                    count++ for value of object
                    space.value = new MoreSigil(count)

                else
                    objectCache.push({ref: object, path: path}) if sigils

                    space.children = {}
                    for key, value of object
                        subspace = toJsonSpace value, space, path.pathByAppendingComponent(key), depthLimit, sigils
                        space.addChild(subspace, key) if subspace?
                
        else
            # What is this thing??
            throw "Don't know how to turn object of type #{typeof(object)} into a JSONSpace"

    space

# Converts a JSONSpace back to a regular object graph, returning references but changing other sigils as it encounters them
fromJsonSpace = (space, references = {}, path = new JSONPath) ->
    ret = undefined
    if space.children? and space.children instanceof Array
        arr = []
        arr.push(fromJsonSpace child, references, path.pathByAppendingComponent i) for child, i in space.children
        ret = arr
    else if space.children?
        obj = {}
        obj[key] = fromJsonSpace(value, references, path.pathByAppendingComponent key) for key, value of space.children
        ret = obj
    else
        if typeof space.value == 'string' and space.value.lastIndexOf(JSONSigil.prefix, 0) == 0
            sigil = JSONSigil.sigilFromName space.value.substr(JSONSigil.prefix.length)
            if not sigil?
                # Assume someone just happens to have encoded an object in our namespace
                ret = space.value
            else if RefSigil.isRefSigil space.value
                references[path] = sigil
                ret = undefined
            else
                ret = sigil.value()
        else
            ret = space.value

    ret

# Module Exports
# --------------

# The current JSON Fu version
exports.VERSION = '0.2.1'

# Allow jpath-like syntax for finding an object in JavaScript object graph
exports.selectObject = (root, jpath) ->
    return undefined if not jpath? or jpath.trim() == ""
    return undefined if not root?

    components = jpath.split('/')
    jsonPath = new JSONPath((component for component in components when component != '')...)
    return new JSONNavigator(root).objectAtPath jsonPath

# Stringify works just like JSON.stringify, with the addition of the depth parameter
exports.stringify = (object, depth = null, replacer = null) ->
    if not depth?
        # Don't use our method because it's slower to figure out the depth
        JSON.stringify object, replacer
    else
        JSON.stringify toJsonSpace(object, null, new JSONPath, depth, no), replacer

# Serialize is like Stringify but is intended to be used when you can use JSONFu's
# deserialize on the other end.  It offers full support for encoding nulls, undefines, 
# functions (not fully supported yet), and references... including circular references
exports.serialize = (object, depth = null, replacer = null) ->
    JSON.stringify toJsonSpace(object, null, new JSONPath, depth, yes), replacer

# Parse is just a passthrough to JSON.parse and is intended to be used when you have not 
# encoded the original json through JSONFu's Serialize function
exports.parse = (json, reviver = null) ->
    JSON.parse json, reviver

# Deserialize functions much like JSON.parse but is better to use when the original data
# was encoded using JSONFu's Serialize function.  Note that normal JSON will be parsed
# just fine with Deserialize, but the overhead is higher
exports.deserialize = (json, reviver = null) ->
    graph = JSON.parse json, reviver
    jsonSpace = toJsonSpace(graph, null, new JSONPath)
    references = {}
    obj = fromJsonSpace jsonSpace, references
    
    # We're done constructing the object graph, now let's resolve
    # all the references
    nav = new JSONNavigator(obj)
    for pathString, sigil of references
        path = JSONPath.fromString pathString
        parent = nav.objectAtPath path.pathByRemovingComponent()
        parent[path.lastComponent()] = sigil.value(obj)
    
    obj

