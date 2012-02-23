namespace eval Spec {
    namespace eval Mocks {
        nx::Class create AnyArgsMatcher {
            :public method description {} {
                return "any args"
            }
        }

        nx::Class create NoArgsMatcher {
            :public method description {} {
                return "no args"
            }
        }

        nx::Class create AnyArgMatcher {
            :public method matches? { other } {
                return true
            }
        }

        nx::Class create BooleanMatcher {
            :public method matches? { other } {
                expr { [string is true $other] || [string is false $other] }
            }
        }

        nx::Class create EqualityMatcher {
            :property for:required

            :public method matches? { other } {
                expr { ${:for} == $other }
            }
        }

        nx::Class create InstanceOfMatcher {
            :property klass:required

            :public method matches? { other } {
                expr { [::nsf::is object $other] && [$other info class] == ${:klass} }
            }
        }

        namespace eval ExampleMethods {
            proc any_args { } {
                ::Spec::Mocks::AnyArgsMatcher new
            }

            proc no_args {} {
                ::Spec::Mocks::NoArgsMatcher new
            }

            proc anything { } {
                ::Spec::Mocks::AnyArgMatcher new
            }            

            proc instance_of { klass } {
                ::Spec::Mocks::InstanceOfMatcher new -klass $klass
            }

            proc boolean { } {
                ::Spec::Mocks::BooleanMatcher new
            }

            namespace export any_args anything instance_of boolean no_args
        }
    }
}