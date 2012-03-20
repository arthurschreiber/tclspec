package require nx

namespace eval Spec {
    nx::Class create World {
        :variable example_groups [list]

        :public method example_groups {} {
            set :example_groups
        }

        :public method register { example_group } {
            lappend :example_groups $example_group
            return $example_group
        }

        :public method example_count { } {
            set count 0

            foreach group ${:example_groups} {
                incr count [llength [$group examples]]
            }

            return $count
        }

        :public method run_hooks { hook context example_group_instance } {
            [Spec configuration] run_hooks $hook $context $example_group_instance
        }
    }
}