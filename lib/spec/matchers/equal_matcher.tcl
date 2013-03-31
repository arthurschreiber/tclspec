namespace eval Spec {
    namespace eval Matchers {
        oo::objdefine ::Spec::Matchers method equal { expected } {
            ::Spec::Matchers::EqualMatcher new $expected
        }

        oo::class create EqualMatcher {
            superclass ::Spec::Matchers::BaseMatcher

            method matches? { actual } {
                my variable expected

                expr { [next $actual] == $expected }
            }

            method failure_message {} {
                my variable actual expected

                return "Expected '$actual' to equal '$expected'"
            }

            method negative_failure_message {} {
                my variable actual expected

                return "Expected '$actual' to not equal '$expected'"
            }
        }
    }
}
