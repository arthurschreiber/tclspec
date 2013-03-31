namespace eval Spec {
    namespace eval Matchers {
        oo::class create BaseMatcher {
            constructor { expected } {
                set [self]::expected $expected
            }

            method matches? { actual } {
                set [self]::actual $actual
            }

            method does_not_match? { actual } {
                expr { ![my matches? $actual] }
            }

            method failure_message {} {
                
            }

            method negative_failure_message {} {
                
            }
        }
    }
}
