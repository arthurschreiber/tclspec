namespace eval Spec {
    namespace eval Matchers {

        ::Spec::Matchers public class method be { args } {
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