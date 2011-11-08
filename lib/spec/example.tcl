package require XOTcl
namespace import xotcl::*

Class create Example
Example instproc init { example_group description block } {
    my set example_group $example_group
    my set description $description
    my set block $block
}

Example instproc full_description { } {
    return "[[my set example_group] full_description] [my set description]"
}

Example instproc before { block } {
    my set before $block
}

Example instproc after { block } {
    my set after $block
}

Example instproc execute { reporter } {
    my start $reporter
    if { [catch { my __execute } message error_options] } {
        my set_error $message $::errorInfo $error_options
    }
    my finish $reporter
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
    Matcher set eval_level "#[info level]"

    uplevel 0 [my set before]
    uplevel 0 [my set block]
    uplevel 0 [my set after]

    # Reset the current stack level so that the value reflects
    # the default stack level value of uplevel.
    Matcher set eval_level 1
}