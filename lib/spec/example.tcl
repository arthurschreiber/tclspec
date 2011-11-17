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

        try {
            [my set example_group_instance] proc expect { args } {
                uplevel [list ::Spec::Matchers expect {*}$args]
            }

            my run_before_each
            [my set example_group_instance] eval [my set block]
            my run_after_each
        } on error { message error_options } {
            set result false
            my set_error $message $::errorInfo $error_options
        } finally {
            [my set example_group_instance] proc expect "" ""

            my finish $reporter
        }

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
        my set error_message $error_message
        my set error_info $error_info
        my set error_options $error_options
    }
}