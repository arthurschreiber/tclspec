namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        Class create Mock
        Mock instproc init { name } {
            my set name $name
            my set expected [list]
            my set called [list]
        }

        Mock instproc should_receive { method_name -with -and_return } {
            my lappend expected $method_name

            if { [info exists and_return] } {
                my proc $method_name { args } "
                    my lappend called $method_name
                    apply {$and_return} {*}\$args
                "
            } else {
                my proc $method_name { args } "
                    my lappend called $method_name
                    return
                "
            }
        }

        Mock instproc should_not_receive { method_name -with } {
            if { [info exists with] } {
                my proc $method_name { args } "
                    puts \"Checking \$args against {$with}\"
                    puts \"it returns \[expr {\$args == {$with} } ]\"
                    if { \$args == {$with} } {
                        return -code error -errorcode MockExpectationError \"bla\"
                    }
                "
            } else {
                my proc $method_name { args } "
                    return -code error -errorcode MockExpectationError \"bla\"
                "
            }
        }

        Mock instproc spec_verify { } {
            set verified true
            foreach exp [my set expected] {
                set verified [expr { $verified && $exp in [my set called] }]
            }
            return $verified
        }

        Mock instproc spec_reset { } {

        }
    }
}