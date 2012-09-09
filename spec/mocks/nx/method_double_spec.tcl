source [file join [file dirname [info script]] ".." ".." "spec_helper.tcl"]

describe "::Spec::Mocks::nx::MethodDouble" {
    before each {
        set class [nx::Class new {
            :class method example_class_method {} {
                return "original"
            }

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

        set object [$class new]

        set proxy [::Spec::Mocks::nx::Proxy new -object $object]

        set method_double [::Spec::Mocks::nx::MethodDouble new -object $object -message_name "example_method" -proxy $proxy]
    }

    describe "#visibility" {
        it "returns 'public' for a public method" {
            set method_double [::Spec::Mocks::nx::MethodDouble new -object $object -message_name "example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "public"
        }

        it "returns 'private' for a private method" {
            set method_double [::Spec::Mocks::nx::MethodDouble new -object $object -message_name "private_example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "private"
        }

        it "returns 'protected' for a protected method" {
            set method_double [::Spec::Mocks::nx::MethodDouble new -object $object -message_name "protected_example_method" -proxy $proxy]
            expect [$method_double visibility] to equal "protected"
        }

        it "returns 'public class' for a class method" {
            set method_double [::Spec::Mocks::nx::MethodDouble new -object $class -message_name "example_class_method" -proxy $proxy]
            expect [$method_double visibility] to equal [list "public" "class"]
        }
    }

    describe "#configure_method" {
        it "should replace the passed method with a stub method on the original object" {
            expect {
                $method_double configure_message
            } to change {
                $object info method body example_method
            }
        }
    }

    describe "#restore_original_method" {
        it "should restore the original method" {
            expect {
                $method_double configure_message
                $method_double restore_original_method
            } to not change {
                $object info method body example_method
            }
        }
    }
}
