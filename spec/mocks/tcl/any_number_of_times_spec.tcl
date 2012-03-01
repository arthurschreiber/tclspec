describe "A Tcl Mock expectation with -any_number_of_times" {
    before each {
        set doubler [::Spec::Mocks::Tcl::Doubler]
        $doubler mock_call "::random_call" -any_number_of_times
    }

    it "passes if the method is not called" {
        expect {
            $doubler spec_verify
        } to not raise_error
    }

    it "passes if the method is called once" {
        ::random_call

        expect {
            $doubler spec_verify
        } to not raise_error
    }

    it "passes if the method is called multiple times" {
        for {set i 0} {$i < 10} {incr i} {
            ::random_call
        }

        expect {
            $doubler spec_verify
        } to not raise_error
    }

    it "is preferred to stubs on the same method" {
        $doubler stub_call "::random_call" -and_return "stub_value"

        $doubler mock_call "::random_call" -any_number_of_times -and_return "mock_value"

        expect [::random_call] to equal "mock_value"
        expect [::random_call] to equal "mock_value"
    }
}