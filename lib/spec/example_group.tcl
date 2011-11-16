package require XOTcl
namespace import xotcl::*

namespace eval Spec {
    Class create ExampleGroupClass -superclass Class

    ExampleGroupClass instproc describe { {description ""} {block {}} } {
        set child [self]::[my autoname Nested_]
        [ExampleGroupClass create $child -superclass [self]]

        $child set description $description

        $child proc describe { args } {
            ::xotcl::classes::Spec::ExampleGroupClass::describe {*}$args
        }

        $child proc it { args } {
            ::xotcl::classes::Spec::ExampleGroupClass::it {*}$args
        }

        $child proc example { args } {
            ::xotcl::classes::Spec::ExampleGroupClass::example {*}$args
        }

        $child proc before { args } {
            ::xotcl::classes::Spec::ExampleGroupClass::before {*}$args
        }

        $child proc after { args } {
            ::xotcl::classes::Spec::ExampleGroupClass::after {*}$args
        }

        $child eval $block
        my lappend children $child

        $child proc describe "" ""
        $child proc it "" ""
        $child proc example "" ""
        $child proc describe "" ""
        $child proc before "" ""
        $child proc after "" ""

        return $child
    }

    ExampleGroupClass instproc init { } {
        next
        my set examples {}
        my set children {}

        my set description ""

        my instvar hooks
        dict set hooks before each { }
        dict set hooks after each { }

        dict set hooks before all { }
        dict set hooks after all { }

        my set before_all_ivars { }
    }

    ExampleGroupClass instproc it { description block } {
        my example $description $block
    }

    ExampleGroupClass instproc example { description block } {
        my lappend examples [Spec::Example new [self] $description $block ]
    }

    ExampleGroupClass instproc register { } {
        [Spec world] register [self]
    }

    ExampleGroupClass instproc full_description {} {
        my set description
    }

    ExampleGroupClass instproc before { what block } {
        my instvar hooks
        dict set hooks before $what [concat [dict get $hooks before $what] [list $block]]
    }

    ExampleGroupClass instproc after { what block } {
        my instvar hooks
        dict set hooks after $what [concat [dict get $hooks after $what] [list $block]]
    }

    ExampleGroupClass instproc children { } {
        my set children
    }

    ExampleGroupClass instproc examples { } {
        my set examples
    }

    ExampleGroupClass instproc run_before_each { example_group_instance } {
        foreach ancestor [lreverse [my ancestors]] {
            foreach hook [dict get [$ancestor set hooks] before each] {
                $example_group_instance eval $hook
            }
        }
    }

    ExampleGroupClass instproc run_after_each { example_group_instance } {
        foreach ancestor [my ancestors] {
            foreach hook [lreverse [dict get [my set hooks] after each]] {
                $example_group_instance eval $hook
            }
        }
    }

    ExampleGroupClass instproc run_before_all { example_group_instance } {
        my instvar before_all_ivars

        dict for { name value } $before_all_ivars {
            $example_group_instance set $name $value
        }

        foreach ancestor [lreverse [my ancestors]] {
            foreach hook [dict get [$ancestor set hooks] before all] {
                $example_group_instance eval $hook
            }
        }

        foreach name [$example_group_instance info vars] {
            dict set before_all_ivars $name [$example_group_instance set $name]
        }
    }

    ExampleGroupClass instproc run_after_all { example_group_instance } {
        dict for { name value } [my set before_all_ivars] {
            $instance set $name $value
        }

        foreach ancestor [my ancestors] {
            foreach hook [lreverse [dict get [$ancestor set hooks] after all]] {
                $example_group_instance eval $hook
            }
        }
    }

    ExampleGroupClass instproc ancestors { } {
        set ancestors {}
        set current_ancestor [self]

        while { $current_ancestor != "::Spec::ExampleGroup" } {
            lappend ancestors $current_ancestor
            set current_ancestor [$current_ancestor superclass]
        }

        return $ancestors
    }

    ExampleGroupClass instproc run { reporter } {
        my instvar children

        $reporter example_group_started [self]

        my run_before_all [my new]

        set result [my run_examples $reporter]

        foreach child $children {
            set result [expr { [$children run $reporter] && $result }]
        }

        my run_after_all [my new]
        my set before_all_ivars { }

        $reporter example_group_finished [self]

        return $result
    }

    ExampleGroupClass instproc before_all_ivars { } {
        my set before_all_ivars
    }

    ExampleGroupClass instproc execute { reporter } {
        my run $reporter
    }

    ExampleGroupClass instproc run_examples { reporter } {
        my instvar examples

        set result true
        foreach example $examples {
            set instance [my new]
            dict for { name value } [my set before_all_ivars] {
                $instance set $name $value
            }
            set result [expr { [$example run $instance $reporter] && $result }]
        }
        return $result
    }

    ExampleGroupClass instproc unknown { args } {
        return -code error -level 1 "[self]: unable to dispatch method '[lindex $args 0]'"
    }

    ExampleGroupClass create ExampleGroup
}