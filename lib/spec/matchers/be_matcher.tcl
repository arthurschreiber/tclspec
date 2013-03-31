namespace eval Spec {
    namespace eval Matchers {
        # Given true, false, or a comparison operator and value, this matcher
        # will pass if the actual value is true, false, or satisfies the given
        # comparison operation.
        #
        # For boolean values, this matcher matches on the passed value using
        # the +string is true+ or +string is false+ commands.
        #
        # For comparison operations, this matcher matches the passed value using
        # the +expr+ using the actual value, the passed operator, and the passed
        # operand.
        #
        # @example
        #   expect $some_value to be true; # Matches if $some_value is 1, true, yes, t, ...
        #   expect $other_value to be false; # Matche if $other_value is 0, false, no, f, ...
        #
        #   expect 20 to be <= 30
        #   expect 50 not to be > 51
        oo::objdefine ::Spec::Matchers method be { args } {
            switch [lindex $args 0] {
                true { ::Spec::Matchers::BeTrueMatcher new }
                false { ::Spec::Matchers::BeFalseMatcher new }
                < - <= - == - != - > - >= - in - ni {
                    ::Spec::Matchers::BeComparedToMatcher new [lindex $args 1] [lindex $args 0]
                }
                default {
                    error "Unknown matcher: 'be $args'"
                }
            }
        }

        oo::class create BeTrueMatcher {
            superclass ::Spec::Matchers::BaseMatcher

            # Takes no arguments
            constructor {} { }

            method matches? { actual } {
                string is true -strict [next $actual]
            }

            method failure_message {} {
                return "Expected '[set [self]::actual]' to be true"
            }
            method negative_failure_message {} {
                return "Expected '[set [self]::actual]' to not be true"
            }
        }

        oo::class create BeFalseMatcher {
            superclass ::Spec::Matchers::BaseMatcher

            constructor { } { }

            method matches? { actual } {
                string is false -strict [next $actual]
            }
            method failure_message {} {
                return "Expected '[set [self]::actual]' to be false"
            }
            method negative_failure_message {} {
                return "Expected '[set [self]::actual]' to not be false"
            }
        }

        oo::class create BeComparedToMatcher {
            superclass ::Spec::Matchers::BaseMatcher

            constructor { operand operator } {
                set [self]::operand $operand
                set [self]::operator $operator
            }

            method matches? { actual } {
                my variable operator operand

                set [self]::actual $actual

                expr "\{$actual\} $operator \{$operand\}"
            }

            method failure_message {} {
                my variable operator operand actual

                if { $operator == "==" } {
                    return "expected: '${operand}'\n     got: '${actual}' (using ${operator})"
                }

                if { ${operator} == "in" } {
                    return "expected '${actual}' to be in '${operand}'"
                }

                return "expected: ${operator} '${operand}'\n     got: [string repeat " " [string length ${operator}]] '${actual}'"
            }

            method negative_failure_message {} {
                my variable operator operand actual

                if { ${operator} == "in" } {
                    return "expected '${actual}' to not be in '${operand}'"
                }

                return "expected not: ${operator} '${operand}'\n         got: [string repeat " " [string length ${operator}]] '${actual}'"
            }
        }
    }
}
