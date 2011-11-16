namespace eval Spec {
    namespace eval Formatters {
        Class create ProgressFormatter -superclass BaseTextFormatter
        ProgressFormatter instproc example_passed { example } {
            next
            puts -nonewline "."
        }

        ProgressFormatter instproc example_failed { example } {
            next
            puts -nonewline "F"
        }

        ProgressFormatter instproc start_dump {} {
            next
            puts ""
        }
    }
}