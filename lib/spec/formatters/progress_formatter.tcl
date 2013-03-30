namespace eval Spec {
    namespace eval Formatters {
        oo::class create ProgressFormatter {
            superclass ::Spec::Formatters::BaseTextFormatter

            method example_passed { example } {
                next $example
                puts -nonewline "."
            }
    
            method example_failed { example } {
                next $example
                puts -nonewline "F"
            }
    
            method start_dump {} {
                next
                puts ""
            }
        }
    }
}
