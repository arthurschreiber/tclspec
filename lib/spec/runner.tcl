namespace eval Spec {
    nx::Class create Runner {
        :public class method autorun {} {
            if { [:installed_at_exit?] } {
                return
            }

            set :installed_at_exit true
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

        :public class method run {} {
            set failure_exit_code 1

            set success true

            set reporter [[::Spec configuration] reporter]
            $reporter report [[Spec world] example_count] {
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

        :public class method installed_at_exit? {} {
            expr { [info exists :installed_at_exit] && ${:installed_at_exit} }
        }
    }
}
