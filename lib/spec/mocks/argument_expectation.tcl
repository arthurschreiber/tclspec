namespace eval Spec {
    namespace eval Mocks {
        nx::Class create ArgumentExpectation {
            :property args:required
            :property {matchers {}}

            :variable match_any_args false

            :protected method init {} {
                if { [llength ${:args}] > 0 } {
                    if { [lindex ${:args} 0] in [::Spec::Mocks::AnyArgsMatcher info instances] } {
                        set :match_any_args true
                    } elseif { [lindex ${:args} 0] in [::Spec::Mocks::NoArgsMatcher info instances] } {
                        set :matchers [list]
                    } else {
                        set :matchers [list]
                        foreach arg ${:args} {
                            lappend :matchers [:matcher_for $arg]
                        }
                    }
                }
            }

            :protected method matcher_for { arg } {
                if { [:is_matcher? $arg] } {
                    return $arg
                } else {
                    ::Spec::Mocks::EqualityMatcher new -for $arg
                }
            }

            :protected method is_matcher? { value } {
                if { [::nsf::is object $value] && "matches?" in [$value info lookup methods] } {
                    return true
                } else {
                    return false
                }
            }

            :public method args_match? { args } {
                expr { ${:match_any_args} || [:matchers_match? {*}$args] }
            }

            :protected method matchers_match? { args } {
                if { [llength $args] != [llength ${:matchers}] } {
                    return false
                }

                set result true
                foreach matcher ${:matchers} arg $args {
                    set result [$matcher matches? $arg]
                    if { !$result } {
                        return false
                    }
                }
                return true
            }
        }
    }
}
