lappend auto_path [file join [file dirname [info script]] ".." ".."]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "Spec::Mocks::MethodDouble" {
    before each {
        set object [nx::Object new {
            :public method example_method {} {
                return "original"
            }

            :protected method protected_example_method {} {
                return "original"
            }

            :private method private_example_method {} {
                return "original"
            }
        }]

        set proxy [::Spec::Mocks::Proxy new -object $object]

        set method_double [Spec::Mocks::MethodDouble new -object $object -method_name "example_method" -proxy $proxy]
    }

    describe "#visibility" {
        it "returns 'public' for a public method" {
            set method_double [Spec::Mocks::MethodDouble new -object $object -method_name "public_example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "public"
        }

        it "returns 'private' for a private method" {
            set method_double [Spec::Mocks::MethodDouble new -object $object -method_name "private_example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "private"
        }

        it "returns 'protected' for a protected method" {
            set method_double [Spec::Mocks::MethodDouble new -object $object -method_name "protected_example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "protected"
        }
    }

    describe "#configure_method" {
        it "should replace the passed method with a stub method on the original object" {
            $method_double configure_method

            expect [$object info method body example_method] to equal "
                    \[:__mock_proxy] message_received example_method {*}\$args
                "
        }
    }

    describe "#restore_original_method" {
        it "should restore the original method" {
            $method_double configure_method
            $method_double restore_original_method

            expect [$object example_method] to equal "original"
        }
    }
}