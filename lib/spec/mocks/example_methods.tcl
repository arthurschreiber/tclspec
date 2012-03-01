namespace eval Spec {
    namespace eval Mocks {
        namespace eval ExampleMethods {
            proc double { args } {
                declare_double "Double" {*}$args
            }

            proc mock { args } {
                declare_double "Mock" {*}$args
            }

            proc stub { args } {
                declare_double "Stub" {*}$args
            }

            # Replace a tcl command with a custom implementation.
            proc stub_call { args } {
                ::Spec::Mocks::Tcl::Doubler stub_call {*}$args
            }

            # Replace a tcl command with a custom implementation and a
            # call expectation.
            proc mock_call { args } {
                ::Spec::Mocks::Tcl::Doubler mock_call {*}$args
            }

            # Replace a tcl command with a negative call expectation.
            proc dont_call { args } {
                ::Spec::Mocks::Tcl::Doubler dont_call {*}$args
            }

            namespace export double mock stub stub_call mock_call dont_call

            proc declare_double { declared_as {name ""} args } {
                ::Spec::Mocks::nx::Mock new -name $name \
                    -options [dict create __declared_as $declared_as]
            }
        }
    }
}