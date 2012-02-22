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

            namespace export double mock stub

            proc declare_double { declared_as {name ""} args } {
                Spec::Mocks::Mock new -name $name
            }
        }
    }
}