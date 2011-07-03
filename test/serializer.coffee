# Serializer Tests
# ----------------

# Some test objects
t1 = 1
t2 = "test"
t3 = 3.14
t4 = yes
t5 = null
t6 = undefined

tA0 = []
tA1 = [t1]
tA2 = [t2]
tA3 = [t3]
tA4 = [t4]
tA5 = [t5]
tA6 = [t6]


stringify = jsonfu.stringify
serialize = jsonfu.serialize

parse = jsonfu.parse
deserialize = jsonfu.deserialize

test "jsonfu's stringify should produce identical output to JSON.stringify", ->
    ok stringify?, "stringify method not found"

    eq stringify(t1), JSON.stringify(t1)
    eq stringify(t2), JSON.stringify(t2)
    eq stringify(t3), JSON.stringify(t3)
    eq stringify(t4), JSON.stringify(t4)
    eq stringify(t5), JSON.stringify(t5)
    eq stringify(t6), JSON.stringify(t6)

    eq stringify(tA1), JSON.stringify(tA1)
    eq stringify(tA2), JSON.stringify(tA2)
    eq stringify(tA3), JSON.stringify(tA3)
    eq stringify(tA4), JSON.stringify(tA4)
    eq stringify(tA5), JSON.stringify(tA5)
    eq stringify(tA6), JSON.stringify(tA6)

test "jsonfu's stringify should have depth support", ->
    shallow = [1, 2, 3]
    eq stringify(shallow, 0), "null"
    eq stringify(shallow, 1), "[1,2,3]"
    eq stringify(shallow, 99), "[1,2,3]"

    medium =
        p1: "one"
        p2: 2
        p3: "three"
        p4: [1, 2, 3, 4]
        p5: 5
        p6: [5, 6, 7]

    eq stringify(medium, 0), "null"
    eq stringify(medium, 1), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p5\":5}"
    eq stringify(medium, 2), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,3,4],\"p5\":5,\"p6\":[5,6,7]}"
    eq stringify(medium, 99), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,3,4],\"p5\":5,\"p6\":[5,6,7]}"

    deep =
        p1: "one"
        p2: 2
        p3: "three"
        p4: [
            1
            2
            {three:3, four:4, five:5}
            6
        ]
        p5: 5
        p6: [5, [6, 7, 8, [9, 10, [11]]]]
    
    eq stringify(deep, 0), "null"
    eq stringify(deep, 1), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p5\":5}"
    eq stringify(deep, 2), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,6],\"p5\":5,\"p6\":[5]}"
    eq stringify(deep, 3), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,{\"three\":3,\"four\":4,\"five\":5},6],\"p5\":5,\"p6\":[5,[6,7,8]]}"
    eq stringify(deep, 4), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,{\"three\":3,\"four\":4,\"five\":5},6],\"p5\":5,\"p6\":[5,[6,7,8,[9,10]]]}"
    eq stringify(deep, 5), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,{\"three\":3,\"four\":4,\"five\":5},6],\"p5\":5,\"p6\":[5,[6,7,8,[9,10,[11]]]]}"
    eq stringify(deep, 99), "{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,{\"three\":3,\"four\":4,\"five\":5},6],\"p5\":5,\"p6\":[5,[6,7,8,[9,10,[11]]]]}"

test "jsonfu's serialize should work like stringify in simple cases", ->

    eq stringify(t1), serialize(t1)
    eq stringify(t2), serialize(t2)
    eq stringify(t3), serialize(t3)
    eq stringify(t4), serialize(t4)

    eq stringify(tA1), serialize(tA1)
    eq stringify(tA2), serialize(tA2)
    eq stringify(tA3), serialize(tA3)
    eq stringify(tA4), serialize(tA4)

    eq stringify({one: "one", two:[3,4,5]}), serialize({one: "one", two:[3,4,5]})

test "jsonfu's serialize should replace null's and undefined with sigils", ->

    eq serialize(t5), "\"__@JSON_null\""
    eq serialize(t6), "\"__@JSON_undefined\""

    eq serialize(tA5), "[\"__@JSON_null\"]"
    eq serialize(tA6), "[\"__@JSON_undefined\"]"

    eq serialize([1, 2, "three", null, "four"]), "[1,2,\"three\",\"__@JSON_null\",\"four\"]"
    eq serialize([1, 2, "three", undefined, "four"]), "[1,2,\"three\",\"__@JSON_undefined\",\"four\"]"
    
test "jsonfu's serialize should replace deep objects with more sigil", ->

    eq serialize([1,2,3,4], 0), "\"__@JSON_more(4)\""
    eq serialize([1,2,3,4], 1), "[1,2,3,4]"

    eq serialize({
        p1: 1
        p2: 2
        p3: [1,2,3,4]
    }, 0), "\"__@JSON_more(3)\""
    
    eq serialize({
        p1: 1
        p2: 2
        p3: [1,2,3,4]
    }, 1), "{\"p1\":1,\"p2\":2,\"p3\":\"__@JSON_more(4)\"}"

    eq serialize({
        p1: 1
        p2: 2
        p3: [1,2,3,4]
    }, 2), "{\"p1\":1,\"p2\":2,\"p3\":[1,2,3,4]}"

test "json's serialize should resolve references, including circular references", ->
    
    commonObj = [1,2,"common"]
    commonObj2 = {foo: "bar", bar: commonObj}
    obj =
        p1: 1
        p2: 2
        p3: commonObj
        p4: 4
        p5: commonObj
        p6: commonObj2

    eq serialize(obj), "{\"p1\":1,\"p2\":2,\"p3\":[1,2,\"common\"],\"p4\":4,\"p5\":\"__@JSON_ref(p3)\",\"p6\":{\"foo\":\"bar\",\"bar\":\"__@JSON_ref(p3)\"}}"

    obj =
        p1: 1
        p2: 2
        p3: 3

    obj["p4"] = obj

    eq serialize(obj), "{\"p1\":1,\"p2\":2,\"p3\":3,\"p4\":\"__@JSON_ref()\"}"

test "json's parse should undo stringify", ->

    deep =
        p1: "one"
        p2: 2
        p3: "three"
        p4: [
            1
            2
            {three:3, four:4, five:5}
            6
        ]
        p5: 5
        p6: [5, [6, 7, 8, [9, 10, [11]]]]
    
    deepEqual parse("{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p5\":5}"), {p1:"one",p2:2,p3:"three",p5:5}
    deepEqual parse("{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,6],\"p5\":5,\"p6\":[5]}"), {p1:"one",p2:2,p3:"three",p4:[1,2,6],p5:5,p6:[5]}
    deepEqual parse("{\"p1\":\"one\",\"p2\":2,\"p3\":\"three\",\"p4\":[1,2,{\"three\":3,\"four\":4,\"five\":5},6],\"p5\":5,\"p6\":[5,[6,7,8,[9,10,[11]]]]}"), deep

test "jsonfu's parse should leave sigils alone", ->
    obj1 = {one:1, two:2}
    obj2 = {three:3, four:obj1, five:undefined, six:obj1}

    json = serialize obj2
    deepEqual parse(json), {three:3,four:{one:1,two:2},five:"__@JSON_undefined",six:"__@JSON_ref(four)"}

test "jsonfu's deserialize should resolve references", ->
    obj1 = {one:1, two:2}
    obj2 = {one:obj1, two:2, three:obj1, four:obj1}

    json = serialize obj2
    deepEqual deserialize(json), {one:{one:1, two:2}, two:2, three:{one:1, two:2}, four:{one:1, two:2}}
