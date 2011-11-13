package require XOTcl
namespace import xotcl::*

namespace eval Spec {
    Class ExampleGroup

    ExampleGroup instproc init { {description ""} } {
        my set description $description
        my set examples {}
        my set before {}
        my set after {}
    }

    ExampleGroup instproc full_description { } {
        my set description
    }

    ExampleGroup instproc before { what block } {
        my set before $block
    }

    ExampleGroup instproc after { what block } {
        my set after $block
    }

    ExampleGroup instproc add { example } {
        my lappend examples $example
    }

    ExampleGroup instproc execute { reporter } {
        my instvar before after examples

        foreach example $examples {
            $example before $before
            $example after $after
            $example execute $reporter
        }
    }
}