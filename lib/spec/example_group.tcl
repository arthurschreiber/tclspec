namespace eval Spec {
    namespace eval ExampleGroupProcs {
        proc describe { args } {
            uplevel 1 [list :describe {*}$args]
        }

        proc context { args } {
            uplevel 1 [list :describe {*}$args]
        }

        proc before { args } {
            uplevel 1 [list :before {*}$args]
        }

        proc after { args } {
            uplevel 1 [list :after {*}$args]
        }

        proc it { args } {
            uplevel 1 [list :example {*}$args]
        }

        proc specify { args } {
            uplevel 1 [list :example {*}$args]
        }

        proc example { args } {
            uplevel 1 [list :example {*}$args]
        }

        proc let { args } {
            uplevel 1 [list :let {*}$args]
        }

        proc let! { args } {
            uplevel 1 [list :let! {*}$args]
        }
    }

    nx::Class create ExampleGroupClass -superclass Class {
        :require method autoname

        :property {description ""}
        :property {children {}}
        :property {examples {}}
        :property {hooks {}}
        :property {before_all_ivars {}}

        :property enclosing_namespace

        :public method init {} {
            :require namespace

            dict set :hooks before each { }
            dict set :hooks after each { }

            dict set :hooks before all { }
            dict set :hooks after all { }
        }

        :public alias instance_eval -frame object ::eval

        :public method describe { {description ""} {block {}} } {
            set child [:]::[:autoname Nested_]
            ExampleGroupClass create $child -superclass [self] -description $description

            # When [::Spec::ExampleGroup describe] is called, we need to store the
            # enclosing namespace, so we can later include it in the namespace path
            # of the individual ExampleGroup instances.
            if { [:] == "::Spec::ExampleGroup" } {
                set enclosing_ns [uplevel { namespace current }]
                if { ![string match ::Spec::* $enclosing_ns] } {
                    $child enclosing_namespace $enclosing_ns
                }
            } else {
                if { [info exists :enclosing_namespace] } {
                    $child enclosing_namespace ${:enclosing_namespace}
                }
            }

            $child instance_eval {
                namespace path [concat [[:info superclass] ancestors] ::Spec::ExampleGroup ::Spec::Matchers ::Spec::ExampleGroupProcs]
            }

            $child instance_eval $block

            lappend :children $child
            return $child
        }

        :public method it { description block } {
            :example $description $block
        }

        :public method example { description block } {
            lappend :examples [::Spec::Example new -example_group [:] -description $description -block $block ]
        }

        :public method register { } {
            [Spec world] register [:]
        }

        :public method full_description {} {
            set full_description ""

            foreach ancestor [lreverse [:ancestors]] {
                set description [$ancestor description]
                if { $full_description == "" || [regexp {^(#|::|\.)} $description] } {
                    append full_description "$description"
                } else {
                    append full_description " $description"
                }
            }

            return $full_description
        }

        :public method before { what block } {
            dict set :hooks before $what [concat [dict get ${:hooks} before $what] [list $block]]
        }

        :public method after { what block } {
            dict set :hooks after $what [concat [dict get ${:hooks} after $what] [list $block]]
        }

        :public method let { name block } {
            :class method $name {} [list uplevel "
                if { !\[info exists :__memoized] } {
                    set :__memoized {}
                }

                if { !\[dict exists \${:__memoized} $name\] } {
                    dict set :__memoized $name \[uplevel { :instance_eval { $block } }\]
                }

                dict get \${:__memoized} $name "]
        }

        :public method let! { name block } {
            :let $name $block
            :before each $name
        }

        :public method setup_mocks { example_group_instance } {
            ::Spec::Mocks setup $example_group_instance
        }

        :public method verify_mocks {} {
            ::Spec::Mocks verify
        }

        :public method teardown_mocks {} {
            ::Spec::Mocks teardown
        }

        :public method run_before_each { example } {
            [Spec world] run_hooks "before" "each" [$example example_group_instance]

            foreach ancestor [lreverse [:ancestors]] {
                foreach hook [dict get [$ancestor hooks] before each] {
                    [$example example_group_instance] instance_eval $hook
                }
            }
        }

        :public method run_after_each { example } {
            [Spec world] run_hooks "after" "each" [$example example_group_instance]

            foreach ancestor [:ancestors] {
                foreach hook [lreverse [dict get [$ancestor hooks] after each]] {
                    [$example example_group_instance] instance_eval $hook
                }
            }
        }

        :public method run_before_all { example_group_instance } {
            dict for { name value } ${:before_all_ivars} {
                $example_group_instance instance_eval [list set $name $value]
            }

            foreach ancestor [lreverse [:ancestors]] {
                foreach hook [dict get [$ancestor hooks] before all] {
                    $example_group_instance instance_eval $hook
                }
            }

            [Spec world] run_hooks "before" "all" $example_group_instance

            foreach name [$example_group_instance info vars] {
                if { [$example_group_instance instance_eval [list array exists $name]] } {
                    foreach {key value} [$example_group_instance instance_eval [list array get $name "*"]] {
                        dict set :before_all_ivars "${name}($key)" [$example_group_instance instance_eval [list set "${name}($key)"]]
                    }
                } else {
                    dict set :before_all_ivars $name [$example_group_instance instance_eval [list set $name]]
                }
            }
        }

        :public method run_after_all { example_group_instance } {
            try {
                dict for { name value } ${:before_all_ivars} {
                    $example_group_instance instance_eval [list set $name $value]
                }

                foreach ancestor [:ancestors] {
                    foreach hook [lreverse [dict get [$ancestor hooks] after all]] {
                        $example_group_instance instance_eval $hook
                    }
                }

                [Spec world] run_hooks "after" "all" $example_group_instance
            } on error { message error_options } {

                puts "
An error occurred in an after all hook.
  [:]: $message
[dict get $error_options -errorinfo]"
            }
        }

        :public method ancestors { } {
            set ancestors {}
            set current_ancestor [:]

            while { $current_ancestor != "::Spec::ExampleGroup" } {
                lappend ancestors $current_ancestor
                set current_ancestor [$current_ancestor info superclass]
            }

            return $ancestors
        }

        :public method run { reporter } {
            $reporter example_group_started [:]

            try {
                :run_before_all [:new]

                set result [:run_examples $reporter]
                foreach child ${:children} {
                    set result [expr { [$child run $reporter] && $result }]
                }
                return $result
            } on error { message error_options } {
                :fail_all_examples $message $error_options $reporter
                return false
            } finally {
                :run_after_all [:new]
                set :before_all_ivars { }

                $reporter example_group_finished [:]
            }
        }

        :protected method fail_all_examples { error_message error_options reporter } {
            foreach example ${:examples} {
                $example fail_with_error $error_message $error_options $reporter
            }
        }

        :public method execute { reporter } {
            :run $reporter
        }

        :public method run_examples { reporter } {
            set result true
            foreach example ${:examples} {
                set instance [:new]
                dict for { name value } [set :before_all_ivars] {
                    $instance instance_eval [list set $name $value]
                }
                set result [expr { [$example run $instance $reporter] && $result }]
            }
            return $result
        }
    }

    ExampleGroupClass create ExampleGroup {
        :public alias instance_eval -frame object ::eval

        :property example

        :public method instance_eval_with_rescue { block } {
            try {
                :instance_eval $block
            } on error { message error_options } {
                if { ![info exists :example] } {
                    return {*}$error_options $message
                }

                ${:example} set_error $message $error_options
            }
        }

        :method init {} {
            :require namespace

            :instance_eval {
                namespace path [concat [[:info class] ancestors] ::Spec::Matchers]
            }

            if { [::nx::var exists [:info class] enclosing_namespace] } {
                :instance_eval {
                    namespace path [concat [namespace path] [[:info class] enclosing_namespace]]
                }
            }
        }
    }
}
