nx::Class create NullObject
NullObject method unknown { args } { }

oo::objdefine ::Spec::Matchers method fail {} {
    my raise_error -code EXPECTATION_NOT_MET
}

oo::objdefine ::Spec::Matchers method fail_with { message } {
    my raise_error -code EXPECTATION_NOT_MET -message $message
}
