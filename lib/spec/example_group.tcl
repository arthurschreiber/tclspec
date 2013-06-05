oo::define oo::object method instance_eval { args } {
    apply [list {} "
        my variable [info object vars [self]]
        [join $args " "]
    " [self namespace]]
}

proc ::oo::define::classmethod {name {args ""} {body ""}} {
    # Create the method on the class if the caller gave arguments and body
    set argc [llength [info level 0]]
    if {$argc == 3} {
        return -code error "wrong # args: should be \"[lindex [info level 0] 0] name ?args body?\""
    }

    # Get the name of the current class or class delegate
    set cls [namespace which [lindex [info level -1] 1]]
    set d $cls.Delegate
    if {[info object isa object $d] && [info object isa class $d]} {
        set cls $d
    }

    if {$argc == 4} {
        oo::define $cls method $name $args $body
    }

    # Make the connection by forwarding
    uplevel 1 [list forward $name [info object namespace $cls]::my $name]
}

# Build this *almost* like a class method, but with extra care to avoid nuking
# the existing method.
oo::class create oo::class.Delegate {
    method create {name {script ""}} {
        if {[string match *.Delegate $name]} {
            return [next $name $script]
        }
        set cls [next $name]
        set delegate [oo::class create $cls.Delegate]
        oo::define $cls $script
        set superdelegates [list $delegate]
        foreach c [info class superclass $cls] {
            set d $c.Delegate
            if {[info object isa object $d] && [info object isa class $d]} {
                lappend superdelegates $d
            }
        }
        oo::objdefine $cls mixin {*}$superdelegates
        return $cls
    }
}

oo::define oo::class self mixin oo::class.Delegate


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

    oo::class create ExampleGroup {
        classmethod subclass { name parent } {
            oo::class create $name [list superclass $parent {*}[info class superclass $parent]]
        }

        classmethod describe { {description ""} {block {}} } {
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

        classmethod children {} {
            my variable children
            return $children
        }

        classmethod description { args } {
            my variable description
            set description {*}$args
        }

        classmethod hooks {} {
            my variable hooks
            return $hooks
        }

        classmethod examples {} {
            my variable examples

            expr { [info exists examples] ? $examples : [list] }
        }

        classmethod parent_groups { } {
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

        classmethod ancestors { } {
            my parent_groups
        }

        classmethod it { description block } {
            my variable examples
            lappend examples [::Spec::Example new [self] $description $block]
        }

        classmethod example { args } {
            my variable examples
            lappend examples [::Spec::Example new [self] {*}$args]
        }

        classmethod register { } {
            [Spec world] register [self]
        }

        classmethod full_description {} {
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

        classmethod before { what block } {
            my variable hooks

            dict set hooks before $what [concat [dict get ${hooks} before $what] [list $block]]
        }

        classmethod after { what block } {
            my variable hooks

            dict set hooks after $what [concat [dict get ${hooks} after $what] [list $block]]
        }

        classmethod let { name block } {
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

        classmethod let! { name block } {
            my let $name $block
            my before each $name
        }

        classmethod setup_mocks { example_group_instance } {
            ::Spec::Mocks setup $example_group_instance
        }

        classmethod verify_mocks {} {
            ::Spec::Mocks verify
        }

        classmethod teardown_mocks {} {
            ::Spec::Mocks teardown
        }

        classmethod run_before_each { example } {
            [Spec world] run_hooks "before" "each" [$example example_group_instance]

            foreach ancestor [lreverse [my parent_groups]] {
                foreach hook [dict get [$ancestor hooks] before each] {
                    [$example example_group_instance] instance_eval $hook
                }
            }
        }

        classmethod run_after_each { example } {
            [Spec world] run_hooks "after" "each" [$example example_group_instance]

            foreach ancestor [my parent_groups] {
                foreach hook [lreverse [dict get [$ancestor hooks] after each]] {
                    [$example example_group_instance] instance_eval $hook
                }
            }
        }

        classmethod run_before_all { example_group_instance } {
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

        classmethod run_after_all { example_group_instance } {
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

        classmethod run { reporter } {
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

        classmethod fail_all_examples { error_message error_options reporter } {
            my variable examples

            foreach example ${examples} {
                $example fail_with_error $error_message $error_options $reporter
            }
        }

        classmethod execute { reporter } {
            my run $reporter
        }

        classmethod run_examples { reporter } {
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
