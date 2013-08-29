oo::define oo::object method instance_eval { args } {
    apply [list {} "
        my variable [info object vars [self]]
        [join $args " "]
    " [self namespace]]
}

namespace eval Spec {
    namespace eval ExampleGroupProcs {
        proc describe { args } {
            uplevel 1 [list my describe {*}$args]
        }

        proc context { args } {
            uplevel 1 [list my describe {*}$args]
        }

        proc before { args } {
            uplevel 1 [list my before {*}$args]
        }

        proc after { args } {
            uplevel 1 [list my after {*}$args]
        }

        proc it { args } {
            uplevel 1 [list my example {*}$args]
        }

        proc specify { args } {
            uplevel 1 [list my example {*}$args]
        }

        proc example { args } {
            uplevel 1 [list my example {*}$args]
        }

        proc let { args } {
            uplevel 1 [list my let {*}$args]
        }

        proc let! { args } {
            uplevel 1 [list my let! {*}$args]
        }

        proc expect { args } {
            uplevel 1 [::Spec::Matchers expect {*}$args]
        }
    }

    ext::class create ExampleGroup {
        meta method subclass { name parent } {
            ext::class create $name [list superclass $parent {*}[info class superclass $parent]]
        }

        meta method describe { {description ""} {block {}} } {
            my variable _subclass_count children
            incr _subclass_count 1

            set child [my subclass "[self]::Nested_${_subclass_count}" [self]]
            $child instance_eval "namespace path \[list ::Spec::ExampleGroupProcs [self namespace] [my eval { namespace path }] {*}\[namespace path]]"

            $child description $description

            $child instance_eval {
                variable hooks
                dict set hooks before each { }
                dict set hooks after each { }
    
                dict set hooks before all { }
                dict set hooks after all { }

                variable before_all_ivars {}
                variable examples [list]
                variable children [list]
            }

            $child instance_eval $block

            lappend children $child
            return $child
        }

        meta method children {} {
            my variable children
            return $children
        }

        meta method description { args } {
            my variable description
            set description {*}$args
        }

        meta method hooks {} {
            my variable hooks
            return $hooks
        }

        meta method examples {} {
            my variable examples

            expr { [info exists examples] ? $examples : [list] }
        }

        meta method parent_groups { } {
            my variable parent_groups

            if { [info exists parent_groups] } {
                return $parent_groups
            }

            set parent_groups [list [self]]

            foreach cls [info class superclass [self]] {
                if { "::Spec::ExampleGroup" in [info class superclass $cls] } {
                    lappend parent_groups $cls
                }
            }

            return $parent_groups
        }

        meta method ancestors { } {
            my parent_groups
        }

        meta method it { description block } {
            my variable examples
            lappend examples [::Spec::Example new [self] $description $block]
        }

        meta method example { args } {
            my variable examples
            lappend examples [::Spec::Example new [self] {*}$args]
        }

        meta method register { } {
            [Spec world] register [self]
        }

        meta method full_description {} {
            set full_description ""

            foreach ancestor [lreverse [my parent_groups]] {
                set description [$ancestor description]
                if { $full_description == "" || [regexp {^(#|::|\.)} $description] } {
                    append full_description "$description"
                } else {
                    append full_description " $description"
                }
            }

            return $full_description
        }

        meta method before { what block } {
            my variable hooks

            dict set hooks before $what [concat [dict get ${hooks} before $what] [list $block]]
        }

        meta method after { what block } {
            my variable hooks

            dict set hooks after $what [concat [dict get ${hooks} after $what] [list $block]]
        }

        meta method let { name block } {
            oo::define [self] method $name {} "
                my variable __memoized
                if { !\[info exists __memoized] } {
                    set __memoized \[dict create]
                }

                if { !\[dict exists \${__memoized} $name\] } {
                    dict set __memoized $name \[my instance_eval { $block }\]
                }

                dict get \${__memoized} $name "

            my eval "proc $name { args } {
                uplevel 1 \[list my $name {*}\$args]
            }"
        }

        meta method let! { name block } {
            my let $name $block
            my before each $name
        }

        meta method setup_mocks { example_group_instance } {
            ::Spec::Mocks setup $example_group_instance
        }

        meta method verify_mocks {} {
            ::Spec::Mocks verify
        }

        meta method teardown_mocks {} {
            ::Spec::Mocks teardown
        }

        meta method run_before_each { example } {
            [Spec world] run_hooks "before" "each" [$example example_group_instance]

            foreach ancestor [lreverse [my parent_groups]] {
                foreach hook [dict get [$ancestor hooks] before each] {
                    [$example example_group_instance] instance_eval $hook
                }
            }
        }

        meta method run_after_each { example } {
            foreach ancestor [my parent_groups] {
                foreach hook [lreverse [dict get [$ancestor hooks] after each]] {
                    [$example example_group_instance] instance_eval $hook
                }
            }

            [Spec world] run_hooks "after" "each" [$example example_group_instance]
        }

        meta method run_before_all { example_group_instance } {
            my variable before_all_ivars

            dict for { name value } ${before_all_ivars} {
                $example_group_instance instance_eval [list variable $name $value]
            }

            foreach ancestor [lreverse [my parent_groups]] {
                foreach hook [dict get [$ancestor hooks] before all] {
                    $example_group_instance instance_eval $hook
                }
            }

            [Spec world] run_hooks "before" "all" $example_group_instance

            foreach full_name [info vars "[info object namespace $example_group_instance]::*"] {
                set name [namespace tail $full_name]

                if { [$example_group_instance instance_eval [list array exists $name]] } {
                    foreach {key value} [$example_group_instance instance_eval [list array get $name "*"]] {
                        dict set before_all_ivars "${name}($key)" [$example_group_instance instance_eval [list set "${name}($key)"]]
                    }
                } else {
                    dict set before_all_ivars $name [$example_group_instance instance_eval [list set $name]]
                }
            }
        }

        meta method run_after_all { example_group_instance } {
            my variable before_all_ivars

            try {
                dict for { name value } ${before_all_ivars} {
                    $example_group_instance instance_eval [list set $name $value]
                }

                foreach ancestor [my parent_groups] {
                    foreach hook [lreverse [dict get [$ancestor hooks] after all]] {
                        $example_group_instance instance_eval $hook
                    }
                }

                [Spec world] run_hooks "after" "all" $example_group_instance
            } on error { message error_options } {

                puts "
An error occurred in an after all hook.
  [self]: $message
[dict get $error_options -errorinfo]"
            }
        }

        meta method run { reporter } {
            my variable children before_all_ivars

            $reporter example_group_started [self]

            try {
                my run_before_all [my new]

                set result [my run_examples $reporter]
                foreach child ${children} {
                    set result [expr { [$child run $reporter] && $result }]
                }
                return $result
            } on error { message error_options } {
                my fail_all_examples $message $error_options $reporter
                return false
            } finally {
                my run_after_all [my new]
                set before_all_ivars { }

                $reporter example_group_finished [self]
            }
        }

        meta method fail_all_examples { error_message error_options reporter } {
            my variable examples

            foreach example ${examples} {
                $example fail_with_error $error_message $error_options $reporter
            }
        }

        meta method execute { reporter } {
            my run $reporter
        }

        meta method run_examples { reporter } {
            my variable examples before_all_ivars

            set result true
            foreach example ${examples} {
                set instance [my new]
                dict for { name value } $before_all_ivars {
                    if { [regexp {^(.+)\((.+)\)$} $name _ array_name key] } {
                        $instance instance_eval "variable $array_name; set $name $value"
                    } else {
                        $instance instance_eval [list variable $name $value]
                    }
                }
                set result [expr { [$example run $instance $reporter] && $result }]
            }
            return $result
        }


        ## Instance methods
        constructor {} {
            set ns_path [list]
            foreach cls [[info object class [self]] parent_groups] {
                lappend ns_path [info object namespace $cls]
            }

            my eval "namespace path \[list $ns_path {*}\[namespace path]]"

            my eval {
                proc expect { args } {
                    uplevel 1 [::Spec::Matchers expect {*}$args]
                }
            }
        }

        method example { args } {
            set [self]::example {*}$args
        }

        method instance_eval_with_rescue { block } {
            my variable example

            try {
                my instance_eval $block
            } on error { message error_options } {
                if { ![info exists example] } {
                    return {*}$error_options $message
                }

                ${example} set_error $message $error_options
            }
        }
    }
}
