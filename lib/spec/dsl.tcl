namespace eval Spec {
    namespace eval DSL {
        proc describe { args } {
            [::Spec::ExampleGroup describe {*}$args] register
        }

        namespace export describe
    }
}

namespace import Spec::DSL::describe