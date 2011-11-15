lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
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

describe "BeComparedToMatcher, with < as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 "<" ]
    }

    it "matches when actual is < expected" {
        my instvar matcher
        expect [ $matcher matches? 3 ] to be true
    }

    it "does not match when actual is not < expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 10 ] to be true
        expect [ $matcher does_not_match? 11 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 11
        expect [ $matcher failure_message ] to equal "expected: < '10'\n     got:   '11'"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 2
        expect [ $matcher negative_failure_message ] to equal "expected not: < '10'\n         got:   '2'"
    }
}

describe "BeComparedToMatcher, with <= as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 "<=" ]
    }

    it "matches when actual is <= expected" {
        my instvar matcher
        expect [ $matcher matches? 3 ] to be true
        expect [ $matcher matches? 10 ] to be true
    }

    it "does not match when actual is not <= expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 11 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 11
        expect [ $matcher failure_message ] to equal "expected: <= '10'\n     got:    '11'"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 2
        expect [ $matcher negative_failure_message ] to equal "expected not: <= '10'\n         got:    '2'"
    }
}

describe "BeComparedToMatcher, with == as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 "==" ]
    }

    it "matches when actual is == expected" {
        my instvar matcher
        expect [ $matcher matches? 10 ] to be true
    }

    it "does not match when actual is not == expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 3 ] to be true
        expect [ $matcher does_not_match? 11 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 11
        expect [ $matcher failure_message ] to equal "expected: '10'\n     got: '11' (using ==)"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 10
        expect [ $matcher negative_failure_message ] to equal "expected not: == '10'\n         got:    '10'"
    }
}

describe "BeComparedToMatcher, with != as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 "!=" ]
    }

    it "matches when actual is != expected" {
        my instvar matcher
        expect [ $matcher matches? 9 ] to be true
    }

    it "does not match when actual is not != expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 10 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 10
        expect [ $matcher failure_message ] to equal "expected: != '10'\n     got:    '10'"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 11
        expect [ $matcher negative_failure_message ] to equal "expected not: != '10'\n         got:    '11'"
    }
}

describe "BeComparedToMatcher, with >= as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 ">=" ]
    }

    it "matches when actual is >= expected" {
        my instvar matcher
        expect [ $matcher matches? 11 ] to be true
        expect [ $matcher matches? 10 ] to be true
    }

    it "does not match when actual is not >= expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 3 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 3
        expect [ $matcher failure_message ] to equal "expected: >= '10'\n     got:    '3'"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 11
        expect [ $matcher negative_failure_message ] to equal "expected not: >= '10'\n         got:    '11'"
    }
}

describe "BeComparedToMatcher, with > as operator" {
    before each {
        my instvar matcher
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 ">" ]
    }

    it "matches when actual is > expected" {
        my instvar matcher
        expect [ $matcher matches? 11 ] to be true
    }

    it "does not match when actual is not > expected" {
        my instvar matcher
        expect [ $matcher does_not_match? 10 ] to be true
    }

    it "provides actual on #failure_message" {
        my instvar matcher
        $matcher matches? 10
        expect [ $matcher failure_message ] to equal "expected: > '10'\n     got:   '10'"
    }

    it "provides actual on #negative_failure_message" {
        my instvar matcher
        $matcher does_not_match? 11
        expect [ $matcher negative_failure_message ] to equal "expected not: > '10'\n         got:   '11'"
    }
}