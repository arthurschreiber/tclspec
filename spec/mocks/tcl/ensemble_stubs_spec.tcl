describe "When mocking a Tcl ensemble subcommand proc" {
    it "should correctly mock the ensemble subcommand proc" {
        mock_call "::clock clicks" -and_return [list "mocked"]
        expect [::clock clicks] to equal "mocked"
    }

    it "should correctly mock the underlying proc" {
        mock_call "::clock clicks" -and_return [list "mocked"]
        expect [::tcl::clock::clicks] to equal "mocked"
    }

    it "should not touch any other ensemble procs" {
        mock_call "::clock clicks" -any_number_of_times -and_return [list "mocked"]
        expect [::clock seconds] to not equal "mocked"
    }
}