source [file join [file dirname [info script]] "mocks/methods_mixin.tcl"]
source [file join [file dirname [info script]] "mocks/method_double.tcl"]
source [file join [file dirname [info script]] "mocks/proxy.tcl"]
source [file join [file dirname [info script]] "mocks/mock.tcl"]
source [file join [file dirname [info script]] "mocks/example_methods.tcl"]
source [file join [file dirname [info script]] "mocks/space.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec
    }

    nx::Class create Mocks {
        :class property [list space [::Spec::Mocks::Space new]]

        :public class method setup { host_namespace } {

        }

        :public class method verify {} {
            :space verify_all
        }

        :public class method teardown {} {
            :space reset_all
        }
    }
}