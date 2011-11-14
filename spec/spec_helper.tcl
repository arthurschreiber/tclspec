Class create NullObject
NullObject instproc unknown { args } { }

::Spec::Matchers proc fail {} {
    my raise_error -code EXPECTATION_NOT_MET
}

::Spec::Matchers proc fail_with { message } {
    my raise_error -code EXPECTATION_NOT_MET -message $message
}
