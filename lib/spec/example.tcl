package require XOTcl
namespace import xotcl::*

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

    Example instproc instance_eval { block } {
        uplevel 0 $block
    }

    Example instproc before { block } {
        my set before $block
    }

    Example instproc after { block } {
        my set after $block
    }

    Example instproc execute { reporter } {
        set result true

        my start $reporter
        if { [catch { my __execute } message error_options] } {
            set result false
            my set_error $message $::errorInfo $error_options
        }
        my finish $reporter

        return $result
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

    Example instproc __execute { } {
        # Store the current stack level, so that blocks passed to
        # matchers are executed in the correct scope.
        Matchers set eval_level "#[info level]"

        uplevel 0 [my set block]

        # Reset the current stack level so that the value reflects
        # the default stack level value of uplevel.
        Matchers set eval_level 1
    }
}