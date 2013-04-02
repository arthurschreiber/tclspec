namespace eval Spec {
    namespace eval Formatters {
        oo::class create BaseFormatter {
            constructor { {output "stdout"} } {
                set [self]::output $output

                set [self]::example_count 0
                set [self]::failure_count 0

                set [self]::duration 0

                set [self]::examples [list]
                set [self]::failed_examples [list]
            }


            method start { example_count } {
                my __start_sync_output
                set [self]::example_count $example_count
            }

            method example_group_started { example_group } {
                
            }

            method example_group_finished { example_group } {

            }

            method example_started { example } {
                lappend [self]::examples $example
            }

            method example_passed { example } {

            }

            method example_failed { example } {
                lappend [self]::failed_examples $example
            }

            method message { message } {

            }

            method stop { } {

            }

            method start_dump { } {

            }

            method dump_failures { } {

            }

            method close { } {
                my __restore_sync_output
            }

            method dump_summary { duration example_count failure_count } {
                set [self]::duration      $duration
                set [self]::example_count $example_count
                set [self]::failure_count $failure_count
            }

            method format_backtrace { $error_info $example } {

            }

            method __start_sync_output {} {
                my variable output

                set [self]::old_buffering [chan configure $output -buffering]
                chan configure $output -buffering "none"
            }

            method __restore_sync_output {} {
                my variable output
                chan configure $output -buffering [set [self]::old_buffering]
            }
        }
    }
}
