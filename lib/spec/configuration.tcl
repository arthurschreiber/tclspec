namespace eval Spec {
    oo::class create HookCollection {
        constructor {} {
            set [self]::hooks [list]
        }

        method append { hook } {
            lappend [self]::hooks $hook
        }

        method prepend { hook } {
            set [self]::hooks [list $hook {*}[set [self]::hooks]]
        }

        method run_all { example_group_instance } {
            foreach hook [set [self]::hooks] {
                $hook run_in $example_group_instance
            }
        }
    }

    oo::class create Hook {
        constructor { block } {
            set [self]::block $block
        }
    }

    oo::class create BeforeHook {
        superclass Hook

        method run_in { example_group_instance } {
            $example_group_instance instance_eval [set [self]::block]
        }
    }

    oo::class create AfterHook {
        superclass Hook

        method run_in { example_group_instance } {
            $example_group_instance instance_eval_with_rescue [set [self]::block]
        }
    }

    oo::class create Configuration {
        constructor { } {
            set [self]::formatters [list]
        }

        method reporter { } {
            my variable reporter formatters

            if { ![info exists reporter] } {
                if { [llength $formatters] == 0 } {
                    my add_formatter "progress"
                }

                set reporter [::Spec::Reporter new -formatters $formatters]
            }

            return $reporter
        }

        method formatters { } {
            set [self]::formatters
        }

        method add_formatter { name } {
            my variable formatters

            if { $name == "doc" } {
                lappend formatters [::Spec::Formatters::DocumentationFormatter new]
            } elseif { $name == "progress" } {
                lappend formatters [::Spec::Formatters::ProgressFormatter new]
            }
        }

        method hooks { } {
            my variable hooks

            if { ![info exists hooks] } {
                set hooks [dict create \
                    before [dict create \
                        each    [Spec::HookCollection new] \
                        all     [Spec::HookCollection new] \
                        suite   [Spec::HookCollection new] \
                    ] \
                    after [dict create \
                        each    [Spec::HookCollection new] \
                        all     [Spec::HookCollection new] \
                        suite   [Spec::HookCollection new] \
                    ]
                ]
            }

            return $hooks
        }

        method run_hooks { hook context {example_group_instance {}} } {
            if { $example_group_instance == {} } {
                set example_group_instance [Spec::ExampleGroup new]
            }

            [dict get [my hooks] $hook $context] run_all $example_group_instance
        }

        method append_before { context block } {
            [dict get [my hooks] before $context] append [BeforeHook new $block]
        }

        forward before my append_before

        method prepend_before { context block } {
            [dict get [my hooks] before $context] prepend [BeforeHook new $block]
        }

        method append_after { context block } {
            [dict get [my hooks] after $context] append [AfterHook new $block]
        }

        forward after my append_after

        method prepend_after { context block } {
            [dict get [my hooks] after $context] prepend [AfterHook new $block]
        }
    }
}
