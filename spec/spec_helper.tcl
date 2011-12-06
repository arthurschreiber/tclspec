package require XOTcl

nx::Class create NullObject
NullObject method unknown { args } { }

::Spec::Matchers public class method fail {} {
    :raise_error -code EXPECTATION_NOT_MET
}

::Spec::Matchers public class method fail_with { message } {
    :raise_error -code EXPECTATION_NOT_MET -message $message
}
