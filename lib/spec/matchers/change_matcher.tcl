namespace eval Spec {
    namespace eval Matchers {
        ::Spec::Matchers proc change { args } {
            ::Spec::Matchers::ChangeMatcher new [list -init {*}$args]
        }

        Class ChangeMatcher -superclass BaseMatcher
        ChangeMatcher instproc init { expected args } {
            next $expected

            if { [dict exists $args by] } {
                my set expected_delta [dict get $args by]
            }

            if { [dict exists $args by_at_most] } {
                my set maximum [dict get $args by_at_most]
            }

            if { [dict exists $args by_at_least] } {
                my set minimum [dict get $args by_at_least]
            }

            if { [dict exists $args from ] } {
                my set expected_before [dict get $args from]
            }

            if { [dict exists $args to ] } {
                my set expected_after [dict get $args to]
            }

        }

        ChangeMatcher instproc change_expected? { } {
            expr { ![my exists expected_delta] || [my set expected_delta] != 0 }
        }

        ChangeMatcher instproc matches? { actual } {
            my set actual $actual

            my set actual_before [uplevel [::Spec::Matchers set eval_level] [my set expected]]
            uplevel [::Spec::Matchers set eval_level] $actual
            my set actual_after [uplevel [::Spec::Matchers set eval_level] [my set expected]]

            expr { (![my change_expected?] || [my changed?]) && [my matches_expected_delta?] && [my matches_max?] && [my matches_min?] && [my matches_before?] && [my matches_after?] }
        }

        ChangeMatcher instproc matches_expected_delta? { } {
            expr { [my exists expected_delta] ? [my actual_delta] == [my set expected_delta] : true }
        }

        ChangeMatcher instproc matches_max? { } {
            expr { [my exists maximum] ? [my actual_delta] <= [my set maximum] : true }
        }

        ChangeMatcher instproc matches_min? { } {
            expr { [my exists minimum] ? [my actual_delta] >= [my set minimum] : true }
        }

        ChangeMatcher instproc matches_before? { } {
            expr { [my exists expected_before] ? [my set actual_before] == [my set expected_before] : true}
        }

        ChangeMatcher instproc matches_after? { } {
            expr { [my exists expected_after] ? [my set actual_after] == [my set expected_after] : true}
        }

        ChangeMatcher instproc actual_delta {} {
            expr { [my set actual_after] - [my set actual_before] }
        }

        ChangeMatcher instproc changed? { } {
            expr { [my set actual_before] != [my set actual_after] }
        }

        ChangeMatcher instproc failure_message {} {
            if { ![my matches_before?] } {
                return "result should have been initially been '[my set expected_before]', but was '[my set actual_before]'"
            } elseif { ![my matches_after?] } {
                return "result should have been changed to '[my set expected_after]', but is now '[my set actual_after]'"
            } elseif { [my exists expected_delta] } {
                return "result should have been changed by '[my set expected_delta]', but was changed by '[my actual_delta]'"
            } elseif { [my exists maximum] } {
                return "result should have been changed by at most '[my set maximum]', but was changed by '[my actual_delta]'"
            } elseif { [my exists minimum] } {
                return "result should have been changed by at least '[my set minimum]', but was changed by '[my actual_delta]'"
            } else {
                return "result should have changed, but is still '[my set actual_before]'"
            }
        }

        ChangeMatcher instproc negative_failure_message {} {
            return "result should not have changed, but did change from '[my set actual_before]' to '[my set actual_after]'"
        }
    }
}