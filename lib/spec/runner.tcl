namespace eval Spec {
    nx::Class create Runner {
        :public class method autorun {} {
            if { [:installed_at_exit?] } {
                return
            }

            set :installed_at_exit true
            at_exit { exit [::Spec::Runner run] }
        }

        :public class method run {} {
            set exit_code 0

            set reporter [Reporter new]
            $reporter report [[Spec world] example_count] {
                foreach example_group [[Spec world] example_groups] {
                    $example_group execute $reporter
                }
            }

            return $exit_code
        }

        :public class method installed_at_exit? {} {
            expr { [info exists :installed_at_exit] && ${:installed_at_exit} }
        }
    }
}