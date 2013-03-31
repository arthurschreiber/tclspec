namespace eval Spec {
    namespace eval Matchers {
        # This Matcher matches checks if the return value of a block changed
        # based on the execution of another block.
        #
        # @example
        #   expect {
        #       $team add_player $player
        #   } to change {
        #       $roster count
        #   }
        #
        #   expect {
        #       $team add_player $player
        #   } to change {
        #       $roster count
        #   } -by 1
        #
        #   expect {
        #       $team add_player $player
        #   } to change {
        #       $roster count
        #   } -by_at_least 1
        #
        #   expect {
        #       $team add_player $player
        #   } to change {
        #       $roster count
        #   } -by_at_most 1
        #
        #   set string "string"
        #   expect {
        #       set string [string reverse $string]
        #   } to change {
        #       return $string
        #   } -from "string" -to "gnirts"
        #
        #   expect {
        #       $person happy_birthday
        #   } to change {
        #       $person age
        #   } -to 33 -from 32
        #
        # @note The negative form of this matcher does not support any options
        #   like +-from+, +-to+, +-by+, +-by_at_most+ or +-by_at_least+.
        oo::objdefine ::Spec::Matchers method change { expected args } {
            set matcher [::Spec::Matchers::ChangeMatcher new $expected]

            if { [dict exists $args "-by"] } {
                $matcher by [dict get $args "-by"]
            }

            if { [dict exists $args "-by_at_most"] } {
                $matcher by_at_most [dict get $args "-by_at_most"]
            }

            if { [dict exists $args "-by_at_least"] } {
                $matcher by_at_least [dict get $args "-by_at_least"]
            }

            if { [dict exists $args "-from"] } {
                $matcher from [dict get $args "-from"]
            }

            if { [dict exists $args "-to"] } {
                $matcher to [dict get $args "-to"]
            }

            return $matcher
        }

        oo::class create ChangeMatcher {
            superclass Spec::Matchers::BaseMatcher

            method by { expected_delta } {
                set [self]::expected_delta $expected_delta
            }

            method by_at_least { minimum } {
                set [self]::minimum $minimum
            }

            method by_at_most { maximum } {
                set [self]::maximum $maximum
            }

            method to { after } {
                set [self]::expected_after $after
            }

            method from { before } {
                set [self]::expected_before $before
            }

            method change_expected? { } {
                my variable expected_delta

                expr { ![info exists expected_delta] || $expected_delta != 0 }
            }


            method matches? { actual } {
                set rc [catch {
                    uplevel [::Spec::Matchers eval_level] [set [self]::expected]
                } result options]

                if { $rc in {0 2} } {
                   set [self]::actual_before $result
                } else {
                    return {*}$options $result
                }

                set rc [catch {
                    uplevel [::Spec::Matchers eval_level] $actual
                } result options]

                if { !($rc in {0 2}) } {
                    return {*}$options $result
                }

                set rc [catch {
                    uplevel [::Spec::Matchers eval_level] [set [self]::expected]
                } result options]

                if { $rc in {0 2} } {
                   set [self]::actual_after $result
                } else {
                    return {*}$options $result
                }

                expr { (![my change_expected?] || [my changed?]) && [my matches_expected_delta?] && [my matches_max?] && [my matches_min?] && [my matches_before?] && [my matches_after?] }
            }

            method matches_expected_delta? { } {
                my variable expected_delta

                expr { [info exists expected_delta] ? [my actual_delta] == ${expected_delta} : true }
            }

            method matches_max? { } {
                my variable maximum

                expr { [info exists maximum] ? [my actual_delta] <= ${maximum} : true }
            }

            method matches_min? { } {
                my variable minimum

                expr { [info exists minimum] ? [my actual_delta] >= ${minimum} : true }
            }

            method matches_before? { } {
                my variable actual_before expected_before

                expr { [info exists expected_before] ? ${actual_before} == ${expected_before} : true}
            }

            method matches_after? { } {
                my variable actual_after expected_after

                expr { [info exists expected_after] ? ${actual_after} == ${expected_after} : true}
            }

            method actual_delta {} {
                my variable actual_before actual_after

                expr { ${actual_after} - ${actual_before} }
            }

            method changed? { } {
                my variable actual_before actual_after

                expr { ${actual_before} != ${actual_after} }
            }

            method failure_message {} {
                my variable expected_before actual_before expected_after actual_after
                my variable expected_delta maximum minimum

                if { ![my matches_before?] } {
                    return "result should have been initially been '${expected_before}', but was '${actual_before}'"
                } elseif { ![my matches_after?] } {
                    return "result should have been changed to '${expected_after}', but is now '${actual_after}'"
                } elseif { [info exists expected_delta] } {
                    return "result should have been changed by '${expected_delta}', but was changed by '[my actual_delta]'"
                } elseif { [info exists maximum] } {
                    return "result should have been changed by at most '${maximum}', but was changed by '[my actual_delta]'"
                } elseif { [info exists minimum] } {
                    return "result should have been changed by at least '${minimum}', but was changed by '[my actual_delta]'"
                } else {
                    return "result should have changed, but is still '${actual_before}'"
                }
            }

            method negative_failure_message {} {
                my variable actual_before actual_after

                return "result should not have changed, but did change from '${actual_before}' to '${actual_after}'"
            }
        }
    }
}
