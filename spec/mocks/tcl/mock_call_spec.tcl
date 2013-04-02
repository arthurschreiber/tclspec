describe "mock_call" {
    it "returns a previous stub_call return value if no new return value is set" {
        stub_call "::something" -with [list "a" "b" "c"] -and_return [list "stubbed_value"]
        mock_call "::something" -with [list "a" "b" "c"]

        expect [::something "a" "b" "c"] to equal "stubbed_value"
        [::Spec::Mocks::Tcl::Doubler new] spec_verify        
    }

    it "returns nohting if no return value is set and there is no previous stub_call return value" {
        mock_call "::something" -with [list "a" "b" "c"]

        expect [::something "a" "b" "c"] to equal ""
        [::Spec::Mocks::Tcl::Doubler new] spec_verify    
    }

    context "when receiving a block" {
        before each {
            variable calls 0
        }

        it "calls the passed block" {
            mock_call "::foo" [list {} { variable calls; incr calls } [namespace current]]

            foo

            expect $calls to equal 1
        }

        it "calls the passed block after a similar stub definition" {
            stub_call "::foo" -and_return [list "bar"]
            mock_call "::foo" [list {} { variable calls; incr calls } [namespace current]]

            foo

            expect $calls to equal 1
        }
    }
}

describe "dont_call" {
    after each {
        [::Spec::Mocks::Tcl::Doubler new] spec_reset
    }

    it "passes when the given proc is not called" {
        dont_call "::not_expected"
        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }

    it "passes when the given proc is called with different args" {
        dont_call "::message" -with [list "unwanted text"]
        mock_call "::message" -with [list "other text"]

        ::message "other text"

        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }

    it "fails when the given proc is called" {
        dont_call "::not_expected"

        expect {
            ::not_expected
            [::Spec::Mocks::Tcl::Doubler new] spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError \
            -message "::not_expected(no args)\n    expected: 0 times\n    received: 1 time"
    }

    it "fails when the given proc is called with args" {
        dont_call "::not_expected" -with [list "unexpected text"]

        expect {
            ::not_expected "unexpected text"
            [::Spec::Mocks::Tcl::Doubler new] spec_verify
        } to raise_error -code ::Spec::Mocks::ExpectationError \
            -message "::not_expected({unexpected text})\n    expected: 0 times\n    received: 1 time"

    }

    it "passes when the given proc is called with wrong args" {
        dont_call "::not_expected" -with [list "unexpected text"]
        ::not_expected "really unexpected text"
        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }

    it "allows a block to calculate the return value" {
        mock_call "::something" -with [list 1 2 3] {{a b c} { expr { $a + $b + $c } }}
        expect [::something 1 2 3] to equal 6
        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }

    it "allows a single return value" {
        mock_call "::something" -with [list "a" "b" "c"] -and_return [list "booh"]
        expect [::something "a" "b" "c"] to equal "booh"
        [::Spec::Mocks::Tcl::Doubler new] spec_verify
    }
}
