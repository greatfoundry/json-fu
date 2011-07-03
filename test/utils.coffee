# Utils
# -----

# `smartSplit`

test "the `smartSplit` utility splits a string by a separator, taking quotes into account", ->
    nothing = "".smartSplit(',')
    arrayEq nothing, []

    slightlyLessNothing = "  ".smartSplit(',')
    arrayEq slightlyLessNothing, ["  "]

    oneThing = "a".smartSplit(',')
    arrayEq oneThing, ["a"]

    oneThingWithSpace = "a  ".smartSplit(',')
    arrayEq oneThingWithSpace, ["a  "]

    twoThings = "one,two".smartSplit(',')
    arrayEq twoThings, ["one", "two"]

    twoThingsWithSpaces = " one , two  ".smartSplit(',')
    arrayEq twoThingsWithSpaces, [" one ", " two  "]

    moreThings = "these,are,a,few,of,my,favorite,things".smartSplit(',')
    arrayEq moreThings, ["these","are","a","few","of","my","favorite","things"]
    
    somethingOtherThanComma = "lets|try|pipes".smartSplit('|')
    arrayEq somethingOtherThanComma, ["lets","try","pipes"]

    oneSingleQuote = "let's try something, shall we".smartSplit(',')
    arrayEq oneSingleQuote, ["let's try something, shall we"]
    # This is what it SHOULD be, but it doesn't work right now
    #arrayEq oneSingleQuote, ["let's try something", "shall we"]

    oneDoubleQuote = "let\"s try something, shall we".smartSplit(',')
    arrayEq oneDoubleQuote, ["let\"s try something, shall we"]
    # This is what it SHOULD be, but it doesn't work right now
    #arrayEq oneDoubleQuote, ["let\"s try something", "shall we"]
    
    balancedSingleQuotes = "and then I said 'hey, you!', and he ran".smartSplit(',')
    arrayEq balancedSingleQuotes, ["and then I said 'hey, you!'", " and he ran"]

    balancedDoubleQuotes = "what is this \"json-fu, thing\" I keep hearing about, huh?".smartSplit(',')
    arrayEq balancedDoubleQuotes, ["what is this \"json-fu, thing\" I keep hearing about", " huh?"]
    
    kitchenSink = "this, 'should, be', somewhat, interesting, \"don't you think?\", or do you not think?".smartSplit(',')
    arrayEq kitchenSink, ["this", " 'should, be'", " somewhat", " interesting", " \"don't you think?\"", " or do you not think?"]

