package require "TclOO" "1.0"

namespace eval Spec {
    oo::class create World {
        variable example_groups [list]

        method example_groups {} {
            set [self]::example_groups
        }

        method register { example_group } {
            lappend [self]::example_groups $example_group
            return $example_group
        }

        method example_count { } {
            set count 0

            foreach group [set [self]::example_groups] {
                incr count [llength [$group examples]]
            }

            return $count
        }

        method run_hooks { hook context example_group_instance } {
            [Spec configuration] run_hooks $hook $context $example_group_instance
        }
    }
}
