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

        $child proc it "" ""
        $child proc example "" ""
        $child proc describe "" ""
        $child proc before "" ""
        $child proc after "" ""

        return $child
    }

    ExampleGroupClass proc unknown "" ""

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
    }

    ExampleGroupClass instproc it { description block } {
        my example $description $block
    }

    ExampleGroupClass instproc example { description block } {
        my lappend examples [Spec::Example new [self] $description $block ]
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

    ExampleGroupClass instproc run_before_each { example } {
        foreach ancestor [lreverse [my ancestors]] {
            foreach hook [dict get [$ancestor set hooks] before each] {
                $example instance_eval $hook
            }
        }
    }

    ExampleGroupClass instproc run_after_each { example } {
        foreach ancestor [my ancestors] {
            foreach hook [lreverse [dict get [my set hooks] after each]] {
                $example instance_eval $hook
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
        my instvar hooks
        my instvar before after examples children

        set result true

        foreach example $examples {
            my run_before_each $example
            set result [expr { [$example execute $reporter] && $result }]
            my run_after_each $example
        }

        foreach child $children {
            set result [expr { [$children run $reporter] && $result }]
        }

        return $result
    }

    ExampleGroupClass instproc execute { reporter } {
        my run $reporter
    }

    ExampleGroupClass instproc run_examples { reporter } {

    }

    ExampleGroupClass create ExampleGroup

    ExampleGroupClass instproc unknown { args } {
        return -code error -level 1 "[self]: unable to dispatch method '[lindex $args 0]'"
    }
}