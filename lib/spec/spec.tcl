package provide spec 0.1

source [file join [file dirname [info script]] "example.tcl"]
source [file join [file dirname [info script]] "example_group.tcl"]
source [file join [file dirname [info script]] "expectation_handler.tcl"]
source [file join [file dirname [info script]] "reporter.tcl"]
source [file join [file dirname [info script]] "world.tcl"]
source [file join [file dirname [info script]] "runner.tcl"]
source [file join [file dirname [info script]] "formatters/base_formatter.tcl"]
source [file join [file dirname [info script]] "formatters/base_text_formatter.tcl"]

source [file join [file dirname [info script]] "matchers.tcl"]

set world [Spec::World new]

proc describe { description block } {
    set group [Spec::ExampleGroup new $description]

    set ::current_group $group

    uplevel 1 $block

    $::world register $group

    unset ::current_group
}

proc it { description block } {
    $::current_group add [Spec::Example new $::current_group $description $block ]
}

proc before { what args } {
    if { [llength $args] == 0 } {
        set block $what
        set what "each"
    } else {
        set block [lindex $args 0]
    }

    $::current_group before $what $block
}

proc after { {what "each"} block } {
    if { [llength $args] == 1 } {
        set what "each"
        set block [lindex $args 0]
    } elseif { [llength $args] == 1 } {
        set what [lindex $args 0]
        set block [lindex $args 1]
    }

    $::current_group after $what $block
}

proc expect { actual to matcher args } {
    set positive true

    # Negative Expectation
    if { $matcher == "not" } {
        set positive false
        set matcher [lindex $args 0]
        set args [lrange $args 1 end]
    }

    if { $matcher == "be" } {
        set what [lindex $args 0]
        set args [lrange $args 1 end]

        if { $what == "true" } {
            set matcher [Spec::Matchers::BeTrueMatcher new]
        } elseif { $what == "false" } {
            set matcher [Spec::Matchers::BeFalseMatcher new]
        } elseif { $what in { < <= > >= in ni } } {
            set expected [lindex $args 0]
            set matcher [Spec::Matchers::BeComparedToMatcher new $expected $what]
        }
    } elseif { $matcher == "equal" } {
        set matcher [Spec::Matchers::EqualMatcher new [list -init {*}$args]]
    } elseif { $matcher == "change" } {
        set matcher [Spec::Matchers::ChangeMatcher new [list -init {*}$args]]
    } elseif { $matcher == "satisfy" } {
        set matcher [Spec::Matchers::SatisfyMatcher new [list -init {*}$args]]
    } elseif { $matcher == "raise_error"} {
        set matcher [Spec::Matchers::RaiseErrorMatcher new [list -init {*}$args]]
    } else {
        error "Unknown Matcher: $matcher"
    }

    if { $positive } {
        Spec::PositiveExpectationHandler handle_matcher $actual $matcher
    } else {
        Spec::NegativeExpectationHandler handle_matcher $actual $matcher
    }
}