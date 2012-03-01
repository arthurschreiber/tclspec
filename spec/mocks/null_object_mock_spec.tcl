lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "a double acting as a null object" {
    before each {
        set double [[double "null object"] as_null_object]
    }

    after each {
        $double spec_reset
    }

    it "should say so" {
        expect [$double null_object?] to be true
    }

    it "allows explicit stubs" {
        $double stub "foo" {{} { return "bar" }}
        expect [$double foo] to equal "bar"
    }

    it "allows explicit expectation" {
        $double should_receive "something"
        $double something
    }

    it "fails verification when explicit expectation is not met" {
        expect {
            $double should_receive "something"
            $double spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError
    }

    it "simply ignores unexpected methods" {
        $double random_call "a" "b" "c"
    }

    it "allows expected messages with different args first" {
        $double should_receive "message" -with { "expected_arg" }
        $double message "unexpected_arg"
        $double message "expected_arg"
    }

    it "allows expected messages with different args first" {
        $double should_receive "message" -with { "expected_arg" }
        $double message "expected_arg"
        $double message "unexpected_arg"
    }
}

describe "a double not acting as a null object" {
    it "should say so" {
        expect [[double "non-null object"] null_object?] to be false
    }
}