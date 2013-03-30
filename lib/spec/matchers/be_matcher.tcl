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
                    ::Spec::Matchers::BeComparedToMatcher new -operator [lindex $args 0] -operand [lindex $args 1]
                }
                default {
                    error "Unknown matcher: 'be $args'"
                }
            }
        }

        nx::Class create BeTrueMatcher -superclass BaseMatcher {
            :public method matches? { actual } {
                string is true -strict [next]
            }

            :public method failure_message {} {
                return "Expected '${:actual}' to be true"
            }
            :public method negative_failure_message {} {
                return "Expected '${:actual}' to not be true"
            }
        }

        nx::Class create BeFalseMatcher -superclass BaseMatcher {
            :public method matches? { actual } {
                string is false -strict [next]
            }
            :public method failure_message {} {
                return "Expected '${:actual}' to be false"
            }
            :public method negative_failure_message {} {
                return "Expected '${:actual}' to not be false"
            }
        }

        nx::Class create BeComparedToMatcher -superclass BaseMatcher {
            :property operator:required
            :property operand:required

            :public method matches? { actual } {
                expr "\{[next]\} ${:operator} \{${:operand}\}"
            }
            :public method failure_message {} {
                if { ${:operator} == "==" } {
                    return "expected: '${:operand}'\n     got: '${:actual}' (using ${:operator})"
                }

                if { ${:operator} == "in" } {
                    return "expected '${:actual}' to be in '${:operand}'"
                }

                return "expected: ${:operator} '${:operand}'\n     got: [string repeat " " [string length ${:operator}]] '${:actual}'"
            }

            :public method negative_failure_message {} {
                if { ${:operator} == "in" } {
                    return "expected '${:actual}' to not be in '${:operand}'"
                }

                return "expected not: ${:operator} '${:operand}'\n         got: [string repeat " " [string length ${:operator}]] '${:actual}'"
            }
        }
    }
}
