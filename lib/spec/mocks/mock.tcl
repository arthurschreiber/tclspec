source [file join [file dirname [info script]] "methods_mixin.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Mock -mixin MethodsMixin {
            :property {name ""}

            :protected method unknown { method_name args } {
                if { ![:null_object?] } {
                    return -code error -errorcode ::Spec::Mocks::ExpectationError "Received unexpected call to $method_name"
                }
            }
        }
    }
}