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
        ::Spec::Matchers public class method change { args } {
            ::Spec::Matchers::ChangeMatcher new -expected [lindex $args 0] {*}[lrange $args 1 end]
        }

        nx::Class create ChangeMatcher -superclass BaseMatcher {
            :property by
            :property by_at_most
            :property by_at_least
            :property from
            :property to

            :public method change_expected? { } {
                expr { ![info exists :by] || ${:by} != 0 }
            }

            :public method matches? { actual } {
                next

                set rc [catch {
                    uplevel [::Spec::Matchers eval_level] ${:expected}
                } result options]

                if { $rc in {0 2} } {
                   set :actual_before $result
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
                    uplevel [::Spec::Matchers eval_level] ${:expected}
                } result options]

                if { $rc in {0 2} } {
                   set :actual_after $result
                } else {
                    return {*}$options $result
                }

                expr { (![:change_expected?] || [:changed?]) && [:matches_expected_delta?] && [:matches_max?] && [:matches_min?] && [:matches_before?] && [:matches_after?] }
            }

            :public method matches_expected_delta? { } {
                expr { [info exists :by] ? [:actual_delta] == ${:by} : true }
            }

            :public method matches_max? { } {
                expr { [info exists :by_at_most] ? [:actual_delta] <= ${:by_at_most} : true }
            }

            :public method matches_min? { } {
                expr { [info exists :by_at_least] ? [:actual_delta] >= ${:by_at_least} : true }
            }

            :public method matches_before? { } {
                expr { [info exists :from] ? ${:actual_before} == ${:from} : true}
            }

            :public method matches_after? { } {
                expr { [info exists :to] ? ${:actual_after} == ${:to} : true}
            }

            :public method actual_delta {} {
                expr { ${:actual_after} - ${:actual_before} }
            }

            :public method changed? { } {
                expr { ${:actual_before} != ${:actual_after} }
            }

            :public method failure_message {} {
                if { ![:matches_before?] } {
                    return "result should have been initially been '${:from}', but was '${:actual_before}'"
                } elseif { ![:matches_after?] } {
                    return "result should have been changed to '${:to}', but is now '${:actual_after}'"
                } elseif { [info exists :by] } {
                    return "result should have been changed by '${:by}', but was changed by '[:actual_delta]'"
                } elseif { [info exists :by_at_most] } {
                    return "result should have been changed by at most '${:by_at_most}', but was changed by '[:actual_delta]'"
                } elseif { [info exists :by_at_least] } {
                    return "result should have been changed by at least '${:by_at_least}', but was changed by '[:actual_delta]'"
                } else {
                    return "result should have changed, but is still '${:actual_before}'"
                }
            }

            :public method negative_failure_message {} {
                return "result should not have changed, but did change from '${:actual_before}' to '${:actual_after}'"
            }
        }
    }
}