namespace eval Spec {
    namespace eval Matchers {
        Class ChangeMatcher -superclass BaseMatcher
        ChangeMatcher instproc init { expected args } {
            next $expected

            if { [dict exists $args by] } {
                my set expected_delta [dict get $args by]
            }
        }

        ChangeMatcher instproc matches? { actual } {
            my set actual $actual

            my set actual_before [uplevel [Matcher set eval_level] [my set expected]]
            uplevel [Matcher set eval_level] $actual
            my set actual_after [uplevel [Matcher set eval_level] [my set expected]]

            expr { [my changed?] && [my matches_expected_delta?] }
        }

        ChangeMatcher instproc does_not_match? { actual } {
            my set actual $actual

            my set actual_before [uplevel [Matcher set eval_level] [my set expected]]
            uplevel [Matcher set eval_level] $actual
            my set actual_after [uplevel [Matcher set eval_level] [my set expected]]

            expr { ![my changed?] || ![my matches_expected_delta?] }
        }

        ChangeMatcher instproc matches_expected_delta? { } {
            expr { [my exists expected_delta] ? [my actual_delta] == [my set expected_delta] : true }
        }

        ChangeMatcher instproc actual_delta {} {
            expr { [my set actual_after] - [my set actual_before] }
        }

        ChangeMatcher instproc changed? { } {
            expr { [my set actual_before] != [my set actual_after] }
        }

        ChangeMatcher instproc positive_failure_message {} {
            if { [my exists expected_delta] } {
                return "{[my set expected]} should have been changed by <[my set expected_delta]>, but was changed by <[my actual_delta]>"
            } else {
                return "{[my set expected]} should have changed, but is still <[my set actual_before]>"
            }
        }
    }
}