namespace eval Spec {
    namespace eval Matchers {
        Class BeTrueMatcher -superclass BaseMatcher
        BeTrueMatcher instproc init {} {

        }
        BeTrueMatcher instproc matches? { actual } {
            string is true [next]
        }
        BeTrueMatcher instproc positive_failure_message {} {
            return "Expected '[my set actual]' to be true"
        }
        BeTrueMatcher instproc negative_failure_message {} {
            return "Expected '[my set actual]' to not be true"
        }

        Class BeFalseMatcher -superclass BaseMatcher
        BeFalseMatcher instproc init {} {

        }
        BeFalseMatcher instproc matches? { actual } {
            string is false [next]
        }
        BeFalseMatcher instproc positive_failure_message {} {
            return "Expected '[my set actual]' to be false"
        }
        BeFalseMatcher instproc negative_failure_message {} {
            return "Expected '[my set actual]' to not be false"
        }

        Class BeComparedToMatcher -superclass BaseMatcher
        BeComparedToMatcher instproc init { operand operator } {
            my set operand $operand
            my set operator $operator
        }
        BeComparedToMatcher instproc matches? { actual } {
            expr "\{[next]\} [my set operator] \{[my set operand]\}"
        }
        BeComparedToMatcher instproc positive_failure_message {} {
            return "Expected '[my set actual]' to be [my set operator] '[my set operand]'"
        }
        BeComparedToMatcher instproc negative_failure_message {} {
            return "Expected '[my set actual]' to not be [my set operator] '[my set operand]'"
        }
    }
}