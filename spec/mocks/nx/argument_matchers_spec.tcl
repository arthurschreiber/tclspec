describe ArgumentMatchers {
    describe "passing argument matchers" {
        before each {
            set double [double "double"]
        }

        it "accepts true as boolean" {
            $double should_receive "random_call" -with [boolean]
            $double random_call true
        }

        it "accepts false as boolean" {
            $double should_receive "random_call" -with [boolean]
            $double random_call false
        }

        it "accepts strings as anything" {
            $double should_receive "random_call" -with [list "a" [anything] "b"]
            $double random_call "a" "whatever" "b"
        }

        it "matches no args against any_args" {
            $double should_receive "random_call" -with [any_args]
            $double random_call
        }

        it "matches one arg against any_args" {
            $double should_receive "random_call" -with [any_args]
            $double random_call
        }

        it "matches no args against no_args" {
            $double should_receive "random_call" -with [no_args]
            $double random_call
        }
    }

    describe "failing argument expectations" {
        before each {
            set double [double "double"]
        }

        after each {
            # We have to reset the expectations here, else we'll get a failure
            # as soon as tclspec verifies the expectations.
            $double spec_reset
        }

        it "rejects non booleans" {
            $double should_receive "random_call" -with [boolean]
            expect {
                $double random_call "something"
            } to raise_error -code "::Spec::Mocks::ExpectationError"
        }

        it "fails no_args with one arg" {
            $double should_receive "random_call" -with [no_args]
            expect {
                $double random_call 42
            } to raise_error -code "::Spec::Mocks::ExpectationError" \
                -message "Double \"double\" received random_call with unexpected arguments\n  expected: (no args)\n       got: (42)"
        }
    }
}