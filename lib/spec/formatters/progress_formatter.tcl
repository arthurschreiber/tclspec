namespace eval Spec {
    namespace eval Formatters {
        nx::Class create ProgressFormatter -superclass BaseTextFormatter {
            :public method example_passed { example } {
                next
                puts -nonewline "."
            }
    
            :public method example_failed { example } {
                next
                puts -nonewline "F"
            }
    
            :public method start_dump {} {
                next
                puts ""
            }
        }
    }
}