lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "expect to be true" {
    it "passes when the actual value is truthy" {
        expect true to be true
        expect tru to be true
        expect tr to be true
        expect t to be true

        expect on to be true

        expect yes to be true
        expect ye to be true
        expect y to be true

        expect 1 to be true
    }

    it "fails when the actual value is not truthy" {
        expect {
            expect "" to be true
        } to fail_with "Expected '' to be true"

        expect {
            expect "test" to be true
        } to fail_with "Expected 'test' to be true"

        expect {
            expect 123 to be true
        } to fail_with "Expected '123' to be true"
    }
}

describe "expect to be false" {
    it "passes when the actual value is falsy" {
        expect false to be false
        expect fals to be false
        expect fal to be false
        expect fa to be false
        expect f to be false

        expect off to be false
        expect of to be false

        expect no to be false
        expect n to be false

        expect 0 to be false
    }

    it "fails when the actual value is not falsy" {
        expect {
            expect "" to be false
        } to fail_with "Expected '' to be false"

        expect {
            expect "test" to be false
        } to fail_with "Expected 'test' to be false"

        expect {
            expect 123 to be false
        } to fail_with "Expected '123' to be false"
    }
}

describe "expect to be <" {
    it "passes when actual is < expected" {
        expect 3 to be < 4
    }

    it "fails when actual is not < expected" {
        expect {
            expect 3 to be < 3
        } to fail_with "expected: < '3'\n     got:   '3'"
    }
}

describe "expect to not be <" {
    it "passes when actual is not < expected" {
        expect 4 to not be < 3
        expect 3 to not be < 3
    }

    it "fails when actual is < expected" {
        expect {
            expect 2 to not be < 3
        } to fail_with "expected not: < '3'\n         got:   '2'"
    }
}

describe "expect to be <=" {
    it "passes when actual is <= expected" {
        expect 3 to be <= 4
        expect 3 to be <= 3
    }

    it "fails when actual is not <= expected" {
        expect {
            expect 4 to be <= 3
        } to fail_with "expected: <= '3'\n     got:    '4'"
    }
}

describe "expect to not be <=" {
    it "passes when actual is not <= expected" {
        expect 4 to not be <= 3
    }

    it "fails when actual is < expected" {
        expect {
            expect 3 to not be <= 3
        } to fail_with "expected not: <= '3'\n         got:    '3'"

        expect {
            expect 2 to not be <= 3
        } to fail_with "expected not: <= '3'\n         got:    '2'"
    }
}

describe "expect to be ==" {
    it "passes when actual is == expected" {
        expect 3 to be == 3
        expect "hello" to be == "hello"
    }

    it "fails when actual is not == expected" {
        expect {
            expect 4 to be == 3
        } to fail_with "expected: '3'\n     got: '4' (using ==)"

        expect {
            expect "hello" to be == "world"
        } to fail_with "expected: 'world'\n     got: 'hello' (using ==)"
    }
}

describe "expect to not be ==" {
    it "passes when actual is == expected" {
        expect 4 to not be == 3
        expect "hello" to not be == "world"
    }

    it "fails when actual is not == expected" {
        expect {
            expect 3 to not be == 3
        } to fail_with "expected not: == '3'\n         got:    '3'"

        expect {
            expect "hello" to not be == "hello"
        } to fail_with "expected not: == 'hello'\n         got:    'hello'"
    }
}

describe "expect to be !=" {
    it "passes when actual is != expected" {
        expect 4 to be != 3
        expect "hello" to be != "world"
    }

    it "fails when actual is not != expected" {
        expect {
            expect 3 to be != 3
        } to fail_with "expected: != '3'\n     got:    '3'"

        expect {
            expect "hello" to be != "hello"
        } to fail_with "expected: != 'hello'\n     got:    'hello'"
    }
}

# This is totally not understandable. Using not be != should output a warning.
describe "expect to not be !=" {
    it "passes when actual is not != expected" {
        expect 4 to not be != 4
        expect "hello" to not be != "hello"
    }

    it "fails when actual is not != expected" {
        expect {
            expect 3 to not be != 4
        } to fail_with "expected not: != '4'\n         got:    '3'"

        expect {
            expect "hello" to not be != "world"
        } to fail_with "expected not: != 'world'\n         got:    'hello'"
    }
}

describe "expect to be >=" {
    it "passes when actual is >= expected" {
        expect 11 to be >= 10
        expect 10 to be >= 10
    }

    it "fails when actual is not >= expected" {
        expect {
            expect 9 to be >= 10
        } to fail_with "expected: >= '10'\n     got:    '9'"
    }
}

describe "expect to not be >=" {
    it "passes when actual is not >= expected" {
        expect 9 to not be >= 10
    }

    it "fails when actual is >= expected" {
        expect {
            expect 10 to not be >= 10
        } to fail_with "expected not: >= '10'\n         got:    '10'"

        expect {
            expect 11 to not be >= 10
        } to fail_with "expected not: >= '10'\n         got:    '11'"
    }
}

describe "expect to be >" {
    it "passes when actual is > expected" {
        expect 11 to be > 10
    }

    it "fails when actual is not > expected" {
        expect {
            expect 10 to be > 10
        } to fail_with "expected: > '10'\n     got:   '10'"
    }
}

describe "expect to not be >" {
    it "passes when actual is not > expected" {
        expect 10 to not be > 10
    }

    it "fails when actual is > expected" {
        expect {
            expect 11 to not be > 10
        } to fail_with "expected not: > '10'\n         got:   '11'"
    }
}

describe "expect to be in" {
    it "passes when actual is in expected" {
        expect "foo" to be in { "foo" "bar" "baz" }
    }

    it "fails when actual is not in expected" {
        expect {
            expect "quox" to be in { "foo" "bar" "baz" }
        } to fail_with "expected 'quox' to be in ' \"foo\" \"bar\" \"baz\" '"
    }
}

describe "expect to not be in" {
    it "passes when actual is in expected" {
        expect "quox" to not be in { "foo" "bar" "baz" }
    }

    it "fails when actual is not in expected" {
        expect {
            expect "baz" to not be in { "foo" "bar" "baz" }
        } to fail_with "expected 'baz' to not be in ' \"foo\" \"bar\" \"baz\" '"
    }
}