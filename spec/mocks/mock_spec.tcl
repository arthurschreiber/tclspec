lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "::Spec::Mocks::Mock" {
    before each {
        set mock [::Spec::Mocks::Mock new -name "test double"]
    }

    after each {
        $mock spec_reset
    }

    it "passes when not receiving message specified as not to be received" {
        $mock should_not_receive "not_expected"
        $mock spec_verify
    }

    it "passes when not receiving message specified as not to be received with different args" {
        $mock should_not_receive "message" -with {"unwanted text"}
        $mock message "other text"
        $mock spec_verify
    }

    it "fails when receiving message specified as not to be received" {
        $mock should_not_receive "not_expected"
        expect {
            $mock not_expected
        } to raise_error -code MockExpectationError
    }

    it "fails when receiving message specified as not to be received with args" {
        $mock should_not_receive "not_expected" -with {"unexpected text"}
        expect {
            $mock not_expected "unexpected text"
        } to raise_error -code MockExpectationError
    }

    it "allows blocks to calculate return values" {
        $mock should_receive "something" -with {"a" "b" "c"} -and_return { {a b c} {
            join [list $a $b $c] ""
        } }

        expect [$mock something "a" "b" "c"] to equal "abc"
        $mock spec_verify
    }

    it "returns the previously stubbed value if no return value was set" {
        $mock stub "something" -with "a" "b" "c" -and_return { {a b c} {
            join [list $a $b $c] ""
        } }
        $mock should_receive "something" -with {"a" "b" "c"}

        expect [$mock something "a" "b" "c"] to equal "abc"
        $mock spec_verify
    }

    it "returns nothing if no return value is set and there is no previously stubbed value" {
        $mock should_receive "something" -with {"a" "b" "c"}

        expect [$mock something "a" "b" "c"] to equal ""
        $mock spec_verify
    }
}