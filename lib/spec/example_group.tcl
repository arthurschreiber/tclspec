package require XOTcl
namespace import xotcl::*

namespace eval Spec {
    Class ExampleGroup

    ExampleGroup instproc init { {description ""} } {
        my set description $description
        my set examples {}

        my instvar hooks
        dict set hooks before each {}
        dict set hooks after each {}

        dict set hooks before all {}
        dict set hooks after all {}
    }

    ExampleGroup instproc full_description { } {
        my set description
    }

    ExampleGroup instproc before { what block } {
        my instvar hooks
        dict set hooks before $what [concat [dict get $hooks before $what] [list $block]]
    }

    ExampleGroup instproc after { what block } {
        my instvar hooks
        dict set hooks after $what [concat [dict get $hooks after $what] [list $block]]
    }

    ExampleGroup instproc example { description block } {
        my lappend examples [Spec::Example new [self] $description $block ]
    }

    ExampleGroup instproc run_before_each { example } {
        foreach hook [dict get [my set hooks] before each] {
            $example instance_eval $hook
        }
    }

    ExampleGroup instproc run_after_each { example } {
        foreach hook [lreverse [dict get [my set hooks] after each]] {
            $example instance_eval $hook
        }
    }

    ExampleGroup instproc run { reporter } {
        my instvar hooks
        my instvar before after examples

        foreach example $examples {
            my run_before_each $example
            $example execute $reporter
            my run_after_each $example
        }
    }

    ExampleGroup instproc execute { reporter } {
        my run $reporter
    }
}