namespace eval Spec {
    namespace eval Matchers {

        ::Spec::Matchers proc be_within { args } {
            ::Spec::Matchers::BeWithinMatcher new {*}$args
        }

        Class BeWithinMatcher -superclass BaseMatcher

        BeWithinMatcher instproc init { delta of expected } {
            my set delta $delta
            next $expected
        }

        BeWithinMatcher instproc matches? { actual } {
            my instvar expected delta

            next

            expr { $actual == $expected || ($actual < $expected + $delta && $actual > $expected - $delta) }
        }

        BeWithinMatcher instproc failure_message {} {
            return "expected [my set actual] to be within [my set delta] of [my set expected]"
        }

        BeWithinMatcher instproc negative_failure_message {} {
            return "expected [my set actual] to not be within [my set delta] of [my set expected]"
        }
    }
}