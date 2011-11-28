namespace eval Spec {
    Class create ExampleGroupClass -superclass Class

    if { $::xotcl::version >= 2.0 } {
        proc stub_for_eval { object methods } {
            $object requireNamespace
            foreach method $methods {
                $object proc $method { args } {
                    if { [catch { ::xotcl::self } ]} {
                        uplevel [list [lindex :[info level 0] 0] {*}$args]
                    } else {
                        ::xotcl::next
                    }
                }
            }
        }
    } else {
        proc stub_for_eval { object methods } {
            $object requireNamespace
            foreach method $methods {
                $object proc $method { args } {
                    ::xotcl::classes::Spec::ExampleGroupClass::[lindex [info level 0] 0] {*}$args
                }
            }
        }
    }

    ExampleGroupClass instproc describe { {description ""} {block {}} } {
        set child [self]::[my autoname Nested_]
        [ExampleGroupClass create $child -superclass [self]]

        $child set description $description

        # When [::Spec::ExampleGroup describe] is called, we need to store the
        # enclosing namespace, so we can later include it in the namespace path
        # of the individual ExampleGroup instances.
        if { [self] == "::Spec::ExampleGroup" } {
            set enclosing_ns [uplevel 2 { namespace current }]

            if { ![string match ::Spec::* $enclosing_ns] } {
                $child set enclosing_namespace $enclosing_ns
            }
        } else {
            if { [[self] exists enclosing_namespace] } {
                $child set enclosing_namespace [[self] set enclosing_namespace]
            }
        }

        # Gives access to the dsl methods when evaluation the passed block
        $child requireNamespace
        $child eval {
            namespace path [concat [[::xotcl::my info superclass] ancestors] ::Spec::ExampleGroup ::Spec::Matchers]
        }

        $child eval $block

        my lappend children $child

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
        my lappend examples [::Spec::Example new -example_group [self] -description $description -block $block ]
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

    ExampleGroupClass instproc let { name block } {
        my proc $name {} "
            if { !\[::xotcl::my exists __memoized] } {
                ::xotcl::my set __memoized {}
            }

            ::xotcl::my instvar __memoized

            if { !\[dict exists \$__memoized $name\] } {
                dict set __memoized $name \[::xotcl::my eval { $block }\]
            }

            dict get \$__memoized $name "
    }

    ExampleGroupClass instproc let! { name block } {
        my let $name $block
        my before each $name
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
            foreach hook [lreverse [dict get [$ancestor set hooks] after each]] {
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
            $example_group_instance set $name $value
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
            set result [expr { [$child run $reporter] && $result }]
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

    stub_for_eval ::Spec::ExampleGroup { "describe" "it" "example" "before" "after" "let" "let!" }

    ExampleGroup instproc init { } {
        my requireNamespace
        my eval {
            namespace path [concat [[::xotcl::my info class] ancestors] ::Spec::Matchers]
        }

        if { [[my info class] exists enclosing_namespace] } {
            my eval "namespace path \[concat \[namespace path] [[my info class] set enclosing_namespace]]"
        }
    }
}