describe "A Mock expectation with -any_number_of_times" {
    before each {
        set obj [oo::object new]
        $obj should_receive "random_call" -any_number_of_times
    }

    it "passes if the method is not called" {
        expect {
            $obj spec_verify
        } to not raise_error
    }

    it "passes if the method is called once" {
        $obj random_call

        expect {
            $obj spec_verify
        } to not raise_error
    }

    it "passes if the method is called multiple times" {
        for {set i 0} {$i < 10} {incr i} {
            $obj random_call
        }

        expect {
            $obj spec_verify
        } to not raise_error
    }

    it "is preferred to stubs on the same method" {
        $obj stub "message" -and_return "stub_value"
        $obj should_receive "message" -any_number_of_times -and_return "mock_value"

        expect [$obj message] to equal "mock_value"
        expect [$obj message] to equal "mock_value"
    }
}
