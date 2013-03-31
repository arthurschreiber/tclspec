namespace eval Spec {
    namespace eval Matchers {
        oo::objdefine ::Spec::Matchers method be_within { delta args } {
            if { [llength $args] != 2 || [lindex $args 0] ni { "of" "percentage_of" } } {
                return -code error "You must set an expected value using 'of' or 'percentage_of': be_within ${delta} of \$expected_value"
            }

            set matcher [::Spec::Matchers::BeWithinMatcher new $delta]
            $matcher {*}$args
            return $matcher
        }

        oo::class create BeWithinMatcher {
            superclass ::Spec::Matchers::BaseMatcher

            constructor { delta } {
                set [self]::delta $delta
            }

            method of { expected } {
                my variable delta

                set [self]::expected $expected
                set [self]::tolerance $delta
                set [self]::unit ""
            }

            method precantage_of { expected } {
                my variable delta

                set [self]::expected $expected
                set [self]::tolerance [expr { $delta * $expected / 100 }]
                set [self]::unit "%"
            }

            method matches? { actual } {
                my variable expected tolerance

                set [self]::actual $actual
                expr { abs($actual - $expected) <= $tolerance }
            }

            method description {} {
                my variable delta unit expected

                return "be within '${delta}${unit}' of '${expected}'"
            }

            method failure_message {} {
                my variable actual

                return "expected '$actual' to [my description]"
            }

            method negative_failure_message {} {
                my variable actual

                return "expected '$actual' to not [my description]"
            }
        }
    }
}
