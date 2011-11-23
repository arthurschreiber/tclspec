namespace eval Spec {
    namespace eval DSL {
        proc describe { args } {
            uplevel "\[::Spec::ExampleGroup describe $args] register"
        }

        namespace export describe
    }
}

namespace import Spec::DSL::describe