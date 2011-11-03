package require XOTcl
namespace import xotcl::*

Class ExampleGroup

ExampleGroup instproc init { description } {
    my set description $description
    my set before {}
    my set after {}
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

ExampleGroup instproc execute {} {
    my instvar before after examples

    foreach example $examples {
        $example before $before
        $example after $after
        $example execute
    }
}