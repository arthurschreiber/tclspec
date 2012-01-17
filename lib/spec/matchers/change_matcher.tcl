namespace eval Spec {
    namespace eval Matchers {
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

                set :actual_before [uplevel [::Spec::Matchers eval_level] ${:expected}]
                uplevel [::Spec::Matchers eval_level] $actual
                set :actual_after [uplevel [::Spec::Matchers eval_level] ${:expected}]

                expr { (![:change_expected?] || [:changed?]) && [:matches_expected_delta?] && [:matches_max?] && [:matches_min?] && [:matches_before?] && [:matches_after?] }
            }

            :public method matches_expected_delta? { } {
                expr { [info exists :by] ? [:actual_delta] == [set :by] : true }
            }

            :public method matches_max? { } {
                expr { [info exists :by_at_most] ? [:actual_delta] <= [set :by_at_most] : true }
            }

            :public method matches_min? { } {
                expr { [info exists :by_at_least] ? [:actual_delta] >= [set :by_at_least] : true }
            }

            :public method matches_before? { } {
                expr { [info exists :from] ? [set :actual_before] == [set :from] : true}
            }

            :public method matches_after? { } {
                expr { [info exists :to] ? [set :actual_after] == [set :to] : true}
            }

            :public method actual_delta {} {
                expr { [set :actual_after] - [set :actual_before] }
            }

            :public method changed? { } {
                expr { [set :actual_before] != [set :actual_after] }
            }

            :public method failure_message {} {
                if { ![my matches_before?] } {
                    return "result should have been initially been '[set :from]', but was '[set :actual_before]'"
                } elseif { ![my matches_after?] } {
                    return "result should have been changed to '[set :to]', but is now '[set :actual_after]'"
                } elseif { [info exists :by] } {
                    return "result should have been changed by '[set :by]', but was changed by '[:actual_delta]'"
                } elseif { [info exists :by_at_most] } {
                    return "result should have been changed by at most '[set :by_at_most]', but was changed by '[:actual_delta]'"
                } elseif { [info exists :by_at_least] } {
                    return "result should have been changed by at least '[set :by_at_least]', but was changed by '[:actual_delta]'"
                } else {
                    return "result should have changed, but is still '[set :actual_before]'"
                }
            }

            :public method negative_failure_message {} {
                return "result should not have changed, but did change from '[set :actual_before]' to '[set :actual_after]'"
            }
        }
    }
}