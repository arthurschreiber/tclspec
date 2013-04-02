describe "A Mock expectation with -any_number_of_times" {
    before each {
        variable mock [::Spec::Mocks::nx::Mock new -name "test mock"]
        $mock should_receive "random_call" -any_number_of_times
    }

    it "passes if the method is not called" {
        expect {
            $mock spec_verify
        } to not raise_error
    }

    it "passes if the method is called once" {
        $mock random_call

        expect {
            $mock spec_verify
        } to not raise_error
    }

    it "passes if the method is called multiple times" {
        for {set i 0} {$i < 10} {incr i} {
            $mock random_call
        }

        expect {
            $mock spec_verify
        } to not raise_error
    }

    it "is preferred to stubs on the same method" {
        $mock stub "message" -and_return "stub_value"
        $mock should_receive "message" -any_number_of_times -and_return "mock_value"

        expect [$mock message] to equal "mock_value"
        expect [$mock message] to equal "mock_value"
    }
}
