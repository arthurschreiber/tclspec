namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Space {
            :variable receivers [list]

            :public method add { receiver } {
                if { [info object isa object $receiver] && [info object class $receiver ReferenceCountable] } {
                    $receiver retain
                }

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

            :public method includes? { receiver } {
                expr { $receiver in ${:receivers} }
            }

            :public method reset_all {} {
                try {
                    foreach receiver ${:receivers} {
                        $receiver spec_reset
                        if { [info object isa object $receiver] && [info object class $receiver ReferenceCountable] } {
                            $receiver release
                        }
                    }
                } finally {
                    set :receivers [list]
                }
            }
        }
    }
}
