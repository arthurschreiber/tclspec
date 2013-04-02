source [file join [file dirname [info script]] ".." ".." "spec_helper.tcl"]

describe "A Tcl mock expectation with multiple return values and no specified count" {
    before each {
        variable doubler [::Spec::Mocks::Tcl::Doubler]
        variable return_values [list 1 "2" [nx::Object new]]

        $doubler mock_call "::message" -and_return $return_values
    }

    after each {
        [$doubler new] spec_reset
    }

    it "returns values in order to consecutive calls" {
        expect [::message] to equal [lindex $return_values 0]
        expect [::message] to equal [lindex $return_values 1]
        expect [::message] to equal [lindex $return_values 2]
        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }

    it "complains when there are too few calls" {
        expect [::message] to equal [lindex $return_values 0]
        expect [::message] to equal [lindex $return_values 1]

        expect {
            [::Spec::Mocks::Tcl::Doubler new] spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError \
          -message "::message(any args)\n    expected: 3 times\n    received: 2 times"
    }

    it "complains when there are too many calls" {
        expect [::message] to equal [lindex $return_values 0]
        expect [::message] to equal [lindex $return_values 1]
        expect [::message] to equal [lindex $return_values 2]
        expect [::message] to equal [lindex $return_values 2]

        expect {
            [::Spec::Mocks::Tcl::Doubler new] spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError \
            -message "::message(any args)\n    expected: 3 times\n    received: 4 times"
    }

    it "doesn't complain when there are too many calls but the method was stubbed" {
        $doubler stub_call "::message" -and_return "stub_result"

        expect [::message] to equal [lindex $return_values 0]
        expect [::message] to equal [lindex $return_values 1]
        expect [::message] to equal [lindex $return_values 2]
        expect [::message] to equal "stub_result"

        expect {
            [::Spec::Mocks::Tcl::Doubler new] spec_verify
        } to not raise_error -code ::Spec::Mocks::ExpectationError
    }
}
