namespace eval Spec {
    namespace eval NamespaceMethods {
        proc describe { args } {
            uplevel [list :describe {*}$args]
        }

        proc context { args } {
            uplevel [list :describe {*}$args]
        }

        proc before { args } {
            uplevel [list :before {*}$args]
        }

        proc after { args } {
            uplevel [list :after {*}$args]
        }

        proc it { args } {
            uplevel [list :example {*}$args]
        }

        proc example { args } {
            uplevel [list :example {*}$args]
        }

        proc let { args } {
            uplevel [list :let {*}$args]
        }

        proc let! { args } {
            uplevel [list :let! {*}$args]
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
                namespace path [concat [[::xotcl::my info superclass] ancestors] ::Spec::ExampleGroup ::Spec::Matchers ::Spec::NamespaceMethods]
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
            set :description
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

        :public method run_before_each { example_group_instance } {
            foreach ancestor [lreverse [:ancestors]] {
                foreach hook [dict get [$ancestor hooks] before each] {
                    $example_group_instance instance_eval $hook
                }
            }
        }

        :public method run_after_each { example_group_instance } {
            foreach ancestor [:ancestors] {
                foreach hook [lreverse [dict get [$ancestor hooks] after each]] {
                    $example_group_instance instance_eval $hook
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

            foreach name [$example_group_instance info vars] {
                dict set :before_all_ivars $name [$example_group_instance instance_eval [list set $name]]
            }
        }

        :public method run_after_all { example_group_instance } {
            dict for { name value } ${:before_all_ivars} {
                $example_group_instance instance_eval [list set $name $value]
            }

            foreach ancestor [:ancestors] {
                foreach hook [lreverse [dict get [$ancestor hooks] after all]] {
                    $example_group_instance instance_eval $hook
                }
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

            :run_before_all [:new]

            set result [:run_examples $reporter]

            foreach child ${:children} {
                set result [expr { [$child run $reporter] && $result }]
            }

            :run_after_all [:new]
            set :before_all_ivars { }

            $reporter example_group_finished [:]

            return $result
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