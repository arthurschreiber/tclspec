describe "A double declaration that is passed an implementation block" {
    describe "using should_receive" {
        it "returns the value of executing the block" {
            set obj [::Spec::Mocks::nx::Mock new]
            $obj should_receive "foo" {{} { return "bar" }}
            expect [$obj foo] to equal "bar"
        }
    }

    describe "using stub" {
        it "returns the value of executing the block" {
            set obj [::Spec::Mocks::nx::Mock new]
            $obj stub "foo" {{} { return "bar" }}
            expect [$obj foo] to equal "bar"
        }
    }
}