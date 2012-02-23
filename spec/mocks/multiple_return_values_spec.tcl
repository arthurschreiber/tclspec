lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "a mock expectation with multiple return values and no specified count" {
    before each {
        set mock [mock "mock"]
        set return_values [list 1 "2" [nx::Object new]]
        $mock should_receive "message" -and_return $return_values
    }

    it "returns values in order to consecutive calls" {
        expect [$mock message] to equal [lindex $return_values 0]
        expect [$mock message] to equal [lindex $return_values 1]
        expect [$mock message] to equal [lindex $return_values 2]
        $mock spec_verify
    }

    it "complains when there are too few calls" {
        expect [$mock message] to equal [lindex $return_values 0]
        expect [$mock message] to equal [lindex $return_values 1]

        expect { $mock spec_verify } to raise_error \
           -code ::Spec::Mocks::ExpectationError \
           -message "(Mock \"mock\").message(any args)\n    expected: 3 times\n    received: 2 times"
    }

    it "complains when there are too many calls" {
        expect [$mock message] to equal [lindex $return_values 0]
        expect [$mock message] to equal [lindex $return_values 1]
        expect [$mock message] to equal [lindex $return_values 2]
        expect [$mock message] to equal [lindex $return_values 2]

        expect { $mock spec_verify } to raise_error \
            -code ::Spec::Mocks::ExpectationError \
            -message "(Mock \"mock\").message(any args)\n    expected: 3 times\n    received: 4 times"
    }

    it "doesn't complain when there are too many calls but the method was stubbed" {
        $mock stub "message" -and_return "stub_result"

        expect [$mock message] to equal [lindex $return_values 0]
        expect [$mock message] to equal [lindex $return_values 1]
        expect [$mock message] to equal [lindex $return_values 2]
        expect [$mock message] to equal "stub_result"

        expect { $mock spec_verify } to not raise_error -code ::Spec::Mocks::ExpectationError
    }
}
