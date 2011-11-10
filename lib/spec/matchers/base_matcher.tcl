namespace eval Spec {
    namespace eval Matchers {
        Class BaseMatcher

        BaseMatcher instproc init { expected } {
            my set expected $expected
        }
        BaseMatcher instproc matches? { actual } {
            my set actual $actual
        }
        BaseMatcher instproc does_not_match? { actual } {
          expr { ![my matches? $actual] }
        }
        BaseMatcher instproc positive_failure_message {} {

        }
        BaseMatcher instproc negative_failure_message {} {

        }
    }
}