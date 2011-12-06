namespace eval Spec {
    namespace eval Matchers {
        nx::Class create BaseMatcher {
            :property expected

            :public method matches? { actual } {
                set :actual $actual
            }

            :public method does_not_match? { actual } {
                expr { ![:matches? $actual] }
            }

            :public method failure_message {} {
                
            }

            :public method negative_failure_message {} {
                
            }
        }
    }
}