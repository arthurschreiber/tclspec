namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Space {
            :variable receivers [list]

            :public method add { receiver } {
                lappend :receivers $receiver
            }

            :public method empty? {} {
                expr { [llength ${:receivers}] == 0 }
            }

            :public method verify_all {} {
                foreach receiver ${:receivers} {
                    $receiver spec_verify
                }
            }

            :public method reset_all {} {
                foreach receiver ${:receivers} {
                    $receiver spec_reset
                }

                set :receivers [list]
            }
        }
    }
}