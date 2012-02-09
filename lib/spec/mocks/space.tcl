namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Space {
            :variable mocks [list]

            :public method empty? {} {
                expr { [llength ${:mocks}] == 0 }
            }

            :public method add { mock } {
                lappend :mocks $mock
            }

            :public method verify_all {} {
                foreach mock ${:mocks} {
                    $mock spec_verify
                }
            }

            :public method reset {} {
                foreach mock ${:mocks} {
                    $mock spec_reset
                }
            }

            :public method reset_all {} {
                :reset
                set :mocks [list]
            }
        }
    }
}