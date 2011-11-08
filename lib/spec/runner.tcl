package require at_exit

package require XOTcl
namespace import xotcl::*

Class create Runner
Runner proc autorun {} {
    if { [my installed_at_exit?] } {
        return
    }

    my set installed_at_exit true
    ::at_exit::at_exit { exit [Runner run] }
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
