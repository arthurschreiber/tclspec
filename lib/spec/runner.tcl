package require XOTcl
namespace import xotcl::*

proc at_exit { block } {
    global at_exit_handlers
    lappend at_exit_handlers $block
}

rename exit orig_exit
proc exit { {code 0} } {
    global at_exit_handlers

    # Allow exiting from inside an exit handler
    rename exit ""
    rename orig_exit exit

    if { [info exists at_exit_handlers] } {
        foreach block $at_exit_handlers {
            if { [catch [list uplevel #0 $block]] } {
                puts $::errorInfo
            }
        }
    }

    exit $code
}

Class create Runner
Runner proc autorun {} {
    if { [my installed_at_exit?] } {
        return
    }

    my set installed_at_exit true
    at_exit { exit [Runner run] }
}

Runner proc run {} {
    set exit_code 0

    set reporter [Reporter new]

    $reporter report [$::world example_count] {
        foreach example_group [$::world set example_groups] {
            $example_group execute $reporter
        }
    }

    return $exit_code
}

Runner proc installed_at_exit? {} {
    expr { [my exists installed_at_exit] && [my set installed_at_exit] }
}
