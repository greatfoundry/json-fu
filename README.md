           _______ ____  _   __      ______     
          / / ___// __ \/ | / /     / ____/_  __
     __  / /\__ \/ / / /  |/ /_____/ /_  / / / /
    / /_/ /___/ / /_/ / /|  /_____/ __/ / /_/ / 
    \____//____/\____/_/ |_/     /_/    \__,_/  

   npm install json-fu

## Overview

JSON-Fu aims to be a collection of kick-ass JSON utilities for JavaScript and CoffeeScript.  Right now,  
it supports the following features:

* Drop-in replacement for JSON.parse and JSON.stringify
* stringify supports the depth parameter just like node's util.inspect
* Fancy serialization and deserialization support with serialize() and deserialize()
* Simple XPath-like query syntax (jPath) for object models

## Serialization

Unlike simple JSON stringification, JSON-Fu's serialization functionality understands references inside the object.  
It even handles circular references!

## "More"

Let's say you want to send a shallow version of a deeper object across the wire.  Wouldn't it be nice if the other side  
not only knew that there was a deeper version available, but how many subobjects there were at the next level?

Example:

    project = {
        name: "My Project",
        client: "A client",
        tasks: [
            0010,
            0011,
            0012,
            0013
        ]
    };

If this were sent accross the wire using:

    jsonfu.serialize(project, 1)

The other end would receive it as:

    project = {
        name: "My Project",
        client: "A client",
        tasks: "__@JSON_more(4)"
    };

The "__@JSON_more(4)" part is called a *sigil*, and it is one of several special values  
that the serializer can emit.  (Note: stringify makes sure to maintain compatibility with 
standard JSON, so you must use serialize() to take advantage of these.)

In this case, client code could detect the presence of the more sigil and not only know
that it could get more information about tasks, but put the number of tasks it would get
(4) on the UI.  This kind of thing usually requires custom code, but it's built in  
to JSON-Fu!

## XPath-like querying with jPath

JSON-Fu has a simple method called "selectObject" that takes a root object and a "jPath"  
query string.  It then returns the object matching that string (or undefined if not found).

Examples:

    object = "test";
    jsonfu.selectObject(object, "/") === "test"

    object = [1,2,3];
    jsonfu.selectObject(object, "/2") === 3

    object = [1, 2, "foo": {bar: "baz"}];
    jsonfu.selectObject(object, "/foo/bar") === "baz"

##### JSON-Fu is Copyright (c) 2011 by [GreatFoundry Software, Inc.](http://www.greatfoundry.com)
##### It is free software under the MIT license
