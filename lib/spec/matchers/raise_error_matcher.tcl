namespace eval Spec {
    namespace eval Matchers {
        Class RaiseErrorMatcher -superclass BaseMatcher
        RaiseErrorMatcher instproc init { args } {

        }

        RaiseErrorMatcher instproc matches? { actual } {
            next
            set rc [catch [list uplevel [Matcher set eval_level] $actual] value]
            expr { $rc == 1 }
        }
    }
}