# jPath Tests
# -----------

test "selectObject basics", ->
    selectObject = jsonfu.selectObject
    ok selectObject, "The selectObject method was not found"

    eq selectObject(), undefined
    eq selectObject(null), undefined
    eq selectObject(null, "/"), undefined

    eq selectObject("test", ""), undefined
    eq selectObject("test", "/"), "test"
    eq selectObject(1, "/"), 1
    eq selectObject(2.344, "/"), 2.344
    arrayEq selectObject([], "/"), []
    arrayEq selectObject(["something"], "/"), ["something"]
    deepEqual selectObject({}, "/"), {}
    deepEqual selectObject({one: "two"}, "/"), {one: "two"}
    notEqual selectObject("test", "/test"), "test"
    notEqual selectObject("test", "/test/one/two"), "test"

test "selectObject deep graphs", ->
    selectObject = jsonfu.selectObject

    eq selectObject(["one"], "/0"), "one"
    eq selectObject(["one"], "/1"), undefined
    eq selectObject(["one", 2, "three", 4], "/2"), "three"
    eq selectObject(["one", "two"], "/1/foo"), undefined
    eq selectObject(["one", ["two", "three", "four"]], "/1/2"), "four"
    arrayEq selectObject(["one", ["two", "three", "four"]], "/1"), ["two", "three", "four"]

    deepEqual selectObject({one: 1}, "/one"), 1
    deepEqual selectObject({one: 1, two: "two", three: false}, "/two"), "two"
    deepEqual selectObject({a: "a", b: [1, 3, 4]}, "/b"), [1, 3, 4]
    
    deepEqual selectObject([0, 1, 2, {a: "a", b: 2, c: [42]}, 4], "/3/c/0"), 42
