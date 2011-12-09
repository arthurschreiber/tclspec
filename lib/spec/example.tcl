namespace eval Spec {
    Class create Example
    Example instproc init { example_group description block } {
        my set example_group $example_group
        my set description $description
        my set block $block
    }

    Example instproc full_description { } {
        return "[[my set example_group] full_description] [my set description]"
    }

    Example instproc description { } {
        my set description
    }

    Example instproc run { example_group_instance reporter } {
        my set example_group_instance $example_group_instance
        set result true

        my start $reporter
        try {
            try {
                my run_before_each
                [my set example_group_instance] eval [my set block]
            } on error { message error_options } {
                my set_error $message [dict get $error_options -errorinfo] $error_options
            } finally {
                my run_after_each
            }
        } on error { message error_options } {
            set result false
            my set_error $message [dict get $error_options -errorinfo] $error_options
        }

        my finish $reporter
        return $result
    }

    Example instproc run_before_each { } {
        [my set example_group] run_before_each [my set example_group_instance]
    }

    Example instproc run_after_each { } {
        [my set example_group] run_after_each [my set example_group_instance]
    }

    Example instproc start { reporter } {
        $reporter example_started [self]
    }

    Example instproc finish { reporter } {
        if { [my exists error_message] } {
            $reporter example_failed [self]
        } else {
            $reporter example_passed [self]
        }
    }

    Example instproc set_error { error_message error_info error_options } {
        if { ![my exists error_message] } {
            my set error_message $error_message
            my set error_info $error_info
            my set error_options $error_options
        }
    }

    Example instproc error_info {} {
        my set error_info
    }
}