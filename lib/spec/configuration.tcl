namespace eval Spec {
    nx::Class create HookCollection {
        :variable hooks [list]

        :public method append { hook } {
            lappend :hooks $hook
        }

        :public method prepend { hook } {
            set :hooks [list $hook {*}${:hooks}]
        }

        :public method run_all { example_group_instance } {
            foreach hook ${:hooks} {
                $hook run_in $example_group_instance
            }
        }
    }

    nx::Class create Hook {
        :property block:required
    }

    nx::Class create BeforeHook -superclass Hook {
        :public method run_in { example_group_instance } {
            $example_group_instance instance_eval ${:block}
        }
    }

    nx::Class create AfterHook -superclass Hook {
        :public method run_in { example_group_instance } {
            $example_group_instance instance_eval_with_rescue ${:block}
        }
    }

    nx::Class create Configuration {
        :property {formatters [list]}

        :variable reporter

        :public method add_formatter { name } {
            if { $name == "doc" } {
                lappend :formatters [::Spec::Formatters::DocumentationFormatter new]
            } elseif { $name == "progress" } {
                lappend :formatters [::Spec::Formatters::ProgressFormatter new]
            }
        }

        :public method reporter { } {
            if { ![info exists :reporter] } {
                if { [llength ${:formatters}] == 0 } {
                    :add_formatter "progress"
                }

                set :reporter [::Spec::Reporter new -formatters ${:formatters}]
            }

            return ${:reporter}
        }

        :public method hooks { } {
            if { ![info exists :hooks] } {
                set :hooks [dict create \
                    before [dict create \
                        each    [HookCollection new] \
                        all     [HookCollection new] \
                        suite   [HookCollection new] \
                    ] \
                    after [dict create \
                        each    [HookCollection new] \
                        all     [HookCollection new] \
                        suite   [HookCollection new] \
                    ]
                ]
            }

            return ${:hooks}
        }

        :public method run_hooks { hook context example_group_instance } {
            [dict get [:hooks] $hook $context] run_all $example_group_instance
        }

        :public method append_before { context block } {
            [dict get [:hooks] before $context] append [BeforeHook new -block $block]
        }

        :public alias before [:info method handle append_before]

        :public method prepend_before { context block } {
            [dict get [:hooks] before $context] prepend [BeforeHook new -block $block]
        }

        :public method append_after { context block } {
            [dict get [:hooks] after $context] append [AfterHook new -block $block]
        }

        :public alias after [:info method handle append_after]

        :public method prepend_after { context block } {
            [dict get [:hooks] after $context] prepend [AfterHook new -block $block]
        }
    }
}