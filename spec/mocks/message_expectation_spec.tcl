lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "Spec::Mocks::MessageExpectation" {
    describe "with a method block" {
        before each {
            set message_expectation [::Spec::Mocks::MessageExpectation new \
                -method_name "example_method" \
                -method_block {{ a b } {
                    expr { $a + $b }
                }}
            ]
        }

        it "it returns the result value of invoking the method block when invoked" {
            expect [$message_expectation invoke 3 4] to equal 7
        }
    }

    describe "without a method block" {
        before each {
            set message_expectation [::Spec::Mocks::MessageExpectation new \
                -method_name "example_method" \
            ]
        }

        it "returns an empty string when invoked" {
            expect [$message_expectation invoke] to equal ""
        }
    }

    describe "when expecting an exact count of invocations" {
        before each {
            set message_expectation [::Spec::Mocks::MessageExpectation new -method_name "example_method"]
            $message_expectation expected_receive_count 2
        }

        describe "when the expected amount of invocations was reached" {
            before each {
                $message_expectation invoke
                $message_expectation invoke
            }

            it "raises no error on verification" {
                expect {
                    $message_expectation verify_messages_received
                } to not raise_error
            }
        }

        describe "when the expected amount of invocations was not reached" {
            before each {
                $message_expectation invoke
            }

            it "raises an error on verification" {
                expect {
                    $message_expectation verify_messages_received
                } to raise_error -code ::Spec::Mocks::ExpectationError
            }
        }

        describe "when the expected amount of invocations was exceeded" {
            before each {
                $message_expectation invoke
                $message_expectation invoke
                $message_expectation invoke
                $message_expectation invoke
            }

            it "raises an error on verification" {
                expect {
                    $message_expectation verify_messages_received
                } to raise_error -code ::Spec::Mocks::ExpectationError
            }
        }
    }
}