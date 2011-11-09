namespace eval Spec {
    namespace eval Matchers {
        Class EqualMatcher -superclass BaseMatcher
        EqualMatcher instproc matches? { actual } {
          expr { [next] == [my set expected] }
        }
        EqualMatcher instproc positive_failure_message {} {
            return "Expected <[my set actual]> to equal <[my set expected]>"
        }
        EqualMatcher instproc negative_failure_message {} {
            return "Expected <[my set actual]> to not equal <[my set expected]>"
        }
    }
}