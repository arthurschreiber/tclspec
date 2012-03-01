source [file join [file dirname [info script]] "mocks/argument_expectation.tcl"]
source [file join [file dirname [info script]] "mocks/message_expectation.tcl"]
source [file join [file dirname [info script]] "mocks/example_methods.tcl"]
source [file join [file dirname [info script]] "mocks/arguments_matchers.tcl"]
source [file join [file dirname [info script]] "mocks/space.tcl"]
source [file join [file dirname [info script]] "mocks/tcl.tcl"]
source [file join [file dirname [info script]] "mocks/nx.tcl"]

namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec
    }

    nx::Class create Mocks {
        :class property [list space [::Spec::Mocks::Space new]]

        :public class method setup { host_namespace } {
            namespace eval $host_namespace {
                namespace import ::Spec::Mocks::ExampleMethods::*
            }

            nx::Object require trait ::Spec::Mocks::Methods
        }

        :public class method verify {} {
            [:space] verify_all
        }

        :public class method teardown {} {
            [:space] reset_all
        }
    }
}