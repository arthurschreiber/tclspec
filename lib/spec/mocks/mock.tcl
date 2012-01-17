namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Mock {
            :property name
            :property [list expected [list]]
            :property [list called [list]]

            :public method should_receive { method_name -with -and_return } {
                lappend :expected $method_name

                if { [info exists and_return] } {
                    :public method $method_name { args } "
                        lappend :called $method_name
                        apply {$and_return} {*}\$args
                    "
                } else {
                    :public method $method_name { args } "
                        lappend :called $method_name
                        return
                    "
                }
            }

            :public method should_not_receive { method_name -with } {
                if { [info exists with] } {

                    :public method $method_name { args } "
                        set called_with \[list $with]

                        if { \$args == \$called_with } {
                            return -code error -errorcode MockExpectationError \"bla\"
                        }
                    "
                } else {
                    :public method $method_name { args } "
                        return -code error -errorcode MockExpectationError \"bla\"
                    "
                }
            }

            :public method spec_verify { } {
                set verified true
                foreach exp ${:expected} {
                    set verified [expr { $verified && $exp in ${:called} }]
                }
                return $verified
            }

           :public method spec_reset { } {

            }
        }
    }
}