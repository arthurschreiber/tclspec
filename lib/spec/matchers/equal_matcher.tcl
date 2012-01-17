namespace eval Spec {
    namespace eval Matchers {
        ::Spec::Matchers public class method equal { expected } {
            ::Spec::Matchers::EqualMatcher new -expected $expected
        }

        nx::Class create EqualMatcher -superclass BaseMatcher {
            :property expected:required

            :public method matches? { actual } {
                expr { [next] == ${:expected} }
            }

            :public method failure_message {} {
                return "Expected '${:actual}' to equal '${:expected}"
            }

            :public method negative_failure_message {} {
                return "Expected '${:actual}' to not equal '${:expected}'"
            }
        }
    }
}