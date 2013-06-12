namespace eval Spec {
    oo::class create Runner {
        self method autorun {} {
            if { [my installed_at_exit?] } {
                return
            }

            my variable installed_at_exit
            set installed_at_exit true

            at_exit {
                # Don't even bother with doing any work when we reached this
                # point due to an error
                if { [info exists ::errorInfo] } {
                    exit 1
                } else {
                    exit [::Spec::Runner run]
                }
            }
        }

        self method run {} {
            set failure_exit_code 1

            set success true

            set reporter [[::Spec configuration] reporter]
            $reporter report [[Spec world] example_count] [[::Spec configuration] seed] {
                try {
                    [Spec configuration] run_hooks "before" "suite"
                    foreach example_group [[Spec world] example_groups] {
                        set success [expr { [$example_group execute $reporter] && $success }]
                    }
                } finally {
                    [Spec configuration] run_hooks "after" "suite"
                }
            }

            expr { $success ? 0 : $failure_exit_code }
        }

        self method installed_at_exit? {} {
            my variable installed_at_exit

            expr { [info exists installed_at_exit] && $installed_at_exit }
        }
    }

    # Make at_exit available inside the Runner class methods
    namespace eval [info object namespace Runner] {
        namespace path [list {*}[namespace path] ::at_exit]
    }
}
