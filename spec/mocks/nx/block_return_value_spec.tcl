describe "A double declaration that is passed an implementation block" {
    describe "using should_receive" {
        it "returns the value of executing the block" {
            set obj [::Spec::Mocks::nx::Mock new]
            $obj should_receive "foo" {{} { return "bar" }}
            expect [$obj foo] to equal "bar"
        }

        describe "if no execution namespace is defined" {
            it "executes the block of code in the same namespace as it was defined in" {
                set obj [::Spec::Mocks::nx::Mock new]
                $obj should_receive "foo" {{} {
                    return [namespace current]
                }}

                expect [$obj foo] to equal [namespace current]
            }
        }

        describe "if an execution namespace is defined" {
            it "executes the block of code in the specified namespace" {
                namespace eval ::HelperNS { }

                set obj [::Spec::Mocks::nx::Mock new]
                $obj should_receive "foo" {{} {
                    return [namespace current]
                } ::HelperNS }

                expect [$obj foo] to equal "::HelperNS"
            }
        }
    }

    describe "using stub" {
        it "returns the value of executing the block" {
            set obj [::Spec::Mocks::nx::Mock new]
            $obj stub "foo" {{} { return "bar" }}
            expect [$obj foo] to equal "bar"
        }

        describe "if no execution namespace is defined" {
            it "executes the block of code in the same namespace as it was defined in" {
                set obj [::Spec::Mocks::nx::Mock new]
                $obj stub "foo" {{} {
                    return [namespace current]
                }}

                expect [$obj foo] to equal [namespace current]
            }
        }

        describe "if an execution namespace is defined" {
            it "executes the block of code in the specified namespace" {
                namespace eval ::HelperNS { }

                set obj [::Spec::Mocks::nx::Mock new]
                $obj stub "foo" {{} {
                    return [namespace current]
                } ::HelperNS }

                expect [$obj foo] to equal "::HelperNS"
            }
        }
    }
}