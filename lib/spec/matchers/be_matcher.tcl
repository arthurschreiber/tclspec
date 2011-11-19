namespace eval Spec {
    namespace eval Matchers {

        ::Spec::Matchers proc be { args } {
            switch [lindex $args 0] {
                true { ::Spec::Matchers::BeTrueMatcher new }
                false { ::Spec::Matchers::BeFalseMatcher new }
                < - <= - > - >= - in - ni {
                    ::Spec::Matchers::BeComparedToMatcher new {*}$args
                }
            }
        }

        Class BeTrueMatcher -superclass BaseMatcher
        BeTrueMatcher instproc init {} {

        }
        BeTrueMatcher instproc matches? { actual } {
            string is true -strict [next]
        }
        BeTrueMatcher instproc failure_message {} {
            return "Expected '[my set actual]' to be true"
        }
        BeTrueMatcher instproc negative_failure_message {} {
            return "Expected '[my set actual]' to not be true"
        }

        Class BeFalseMatcher -superclass BaseMatcher
        BeFalseMatcher instproc init {} {

        }
        BeFalseMatcher instproc matches? { actual } {
            string is false -strict [next]
        }
        BeFalseMatcher instproc failure_message {} {
            return "Expected '[my set actual]' to be false"
        }
        BeFalseMatcher instproc negative_failure_message {} {
            return "Expected '[my set actual]' to not be false"
        }

        Class BeComparedToMatcher -superclass BaseMatcher
        BeComparedToMatcher instproc init { operator operand } {
            my set operand $operand
            my set operator $operator
        }
        BeComparedToMatcher instproc matches? { actual } {
            expr "\{[next]\} [my set operator] \{[my set operand]\}"
        }
        BeComparedToMatcher instproc failure_message {} {
            if { [my set operator] == "==" } {
                return "expected: '[my set operand]'\n     got: '[my set actual]' (using [my set operator])"
            }

            if { [my set operator] == "in" } {
                return "expected '[my set actual]' to be in '[my set operand]'"
            }

            return "expected: [my set operator] '[my set operand]'\n     got: [string repeat " " [string length [my set operator]]] '[my set actual]'"
        }

        BeComparedToMatcher instproc negative_failure_message {} {
            if { [my set operator] == "in" } {
                return "expected '[my set actual]' to not be in '[my set operand]'"
            }

            return "expected not: [my set operator] '[my set operand]'\n         got: [string repeat " " [string length [my set operator]]] '[my set actual]'"
        }
    }
}