namespace eval Spec {
    oo::class create Example {
        constructor { example_group description block } {
            set [self]::example_group $example_group
            set [self]::description $description
            set [self]::block $block
        }

        method error_info {} {
            set [self]::error_info
        }

        method example_group_instance {} {
            set [self]::example_group_instance
        }

        method full_description {} {
            my variable example_group description

            return [$example_group full_description] $description
        }

        method description {} {
            set [self]::description
        }

        method run { example_group_instance reporter } {
            set [self]::example_group_instance $example_group_instance
            $example_group_instance example [self]

            my start $reporter
            try {
                try {
                    my run_before_each_hooks
                    $example_group_instance instance_eval [set [self]::block]
                } on error { message error_options } {
                    my set_error $message $error_options
                } finally {
                    my run_after_each_hooks
                }
            } on error { message error_options } {
                my set_error $message $error_options
            }

            my finish $reporter
        }

        method run_before_each_hooks { } {
            my variable example_group example_group_instance

            ${example_group} setup_mocks ${example_group_instance}
            ${example_group} run_before_each [self]
        }

        method run_after_each_hooks { } {
            my variable example_group

            try {
                ${example_group} run_after_each [self]
                ${example_group} verify_mocks
            } finally {
                ${example_group} teardown_mocks
            }
        }

        method fail_with_error { error_message error_options reporter } {
            my start $reporter
            my set_error $error_message $error_options
            my finish $reporter
        }

        method start { reporter } {
            $reporter example_started [self]
        }

        method finish { reporter } {
            if { [info exists [self]::error_message] } {
                $reporter example_failed [self]
                return false
            } else {
                $reporter example_passed [self]
                return true
            }
        }

        method set_error { error_message error_options } {
            if { ![info exists [self]::error_message] } {
                set [self]::error_message $error_message
                set [self]::error_info [dict get $error_options -errorinfo]
                set [self]::error_options $error_options
            }
        }
    }
}
