package require XOTcl
namespace import xotcl::*

Class create World
World instproc init { } {
    my set example_groups {}
}

World instproc example_groups { } {
    my set example_groups
}

World instproc register { example_group } {
    my lappend example_groups $example_group
}

World instproc example_count { } {
    set count 0

    foreach group [my set example_groups] {
        incr count [llength [$group set examples]]
    }

    return $count
}