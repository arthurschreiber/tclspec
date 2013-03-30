namespace eval Spec {
    namespace eval Matchers {
        oo::objdefine ::Spec::Matchers method be_within { delta of expected } {
            ::Spec::Matchers::BeWithinMatcher new -delta $delta -expected $expected
        }

        nx::Class create BeWithinMatcher -superclass BaseMatcher {
            :property delta:required
            :property expected:required

            :public method matches? { actual } {
                next

                expr { ${:actual} == ${:expected} || (${:actual} < ${:expected} + ${:delta} && ${:actual} > ${:expected} - ${:delta})}
            }

            :public method failure_message {} {
                return "expected '${:actual}' to be within '${:delta}' of '${:expected}'"
            }

            :public method negative_failure_message {} {
                return "expected '${:actual}' to not be within '${:delta}' of '${:expected}'"
            }
        }
    }
}
