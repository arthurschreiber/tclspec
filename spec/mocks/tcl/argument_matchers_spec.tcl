describe "ArgumentMatchers with Tcl mocks" {
    context "passing argument matchers" {
        it "accepts true as boolean" {
            mock_call "::random_call" -with [boolean]
            ::random_call true
        }

        it "accepts false as boolean" {
            mock_call "::random_call" -with [boolean]
            ::random_call false
        }

        it "accepts strings as anything" {
            mock_call "::random_call" -with [list "a" [anything] "b"]
            ::random_call "a" "whatever" "b"
        }

        it "matches no args against any_args" {
            mock_call "::random_call" -with [any_args]
            ::random_call
        }

        it "matches one arg against any_args" {
            mock_call "::random_call" -with [any_args]
            ::random_call
        }

        it "matches no args against no_args" {
            mock_call "::random_call" -with [no_args]
            ::random_call
        }
    }

    context "failing argument expectations" {
        after each {
            [::Spec::Mocks::Tcl::Doubler new] spec_reset
        }

        it "rejects non booleans" {
            mock_call "::random_call" -with [boolean]
            expect {
                ::random_call "something"
            } to raise_error -code "::Spec::Mocks::ExpectationError"
        }

        it "fails no_args with one arg" {
            mock_call "::random_call" -with [no_args]
            expect {
                ::random_call 42
            } to raise_error -code "::Spec::Mocks::ExpectationError" \
                -message "Received call to ::random_call with unexpected arguments\n  expected: (no args)\n       got: (42)"
        }
    }
}