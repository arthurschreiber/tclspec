source [file join [file dirname [info script]] "methods.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        nx::Class create Mock {
            :require trait ::Spec::Mocks::Methods

            :property {name ""}
            :property {options {}}

            :protected method unknown { method_name args } {
                if { ![:null_object?] } {
                    [:__mock_proxy] raise_unexpected_message_error $method_name {*}$args
                }
            }
        }
    }
}