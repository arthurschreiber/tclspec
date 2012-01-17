source [file join [file dirname [info script]] "mocks/mock.tcl"]
source [file join [file dirname [info script]] "mocks/space.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec
    }

    nx::Class create Mocks {
        :property [list space [::Spec::Mocks::Space new]]

        :public method setup { host_namespace } {

        }

        :public method verify {} {
            :space verify_all
        }

        :public method teardown {} {
            :space reset_all
        }
    }
}