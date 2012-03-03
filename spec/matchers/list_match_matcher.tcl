source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "expect <actual> to be =~ <expected>" {
    it "passes if actual and expected contain the same items" {
        expect [list 1 2 3] to be =~ [list 1 2 3]
    }

    it "passes if actual and expected contain the same items in different order" {
        expect [list 1 3 2] to be =~ [list 1 2 3]
    }

    it "fails if actual includes extra items" {
        expect {
            expect [list 1 2 3 4] to be =~ [list 1 2 3]
        } to fail_with ""
    }

    it "fails if actual misses items" {
        expect {
            expect [list 1 2] to be =~ [list 1 2 3]
        } to fail_with ""
    }

    it "fails if actual misses items and includes extra items" {
        expect {
            expect [list 1 2 4] to be =~ [list 1 2 3]
        } to fail_with ""
    }

    it "sorts items in the error message" {
        expect {
            expect [list 6 2 1 5] to be =~ [list 4 1 2 3]
        } to fail_with ""
    }

    it "accurately reports extra elements when there are duplicates" {
        expect {
            expect [list 1 1 1 5] to =~ [list 1 5]
        } to fail_with ""
    }

    it "accurately reports missing elements when there are duplicates" {
        expect {
            expect [list 1 5] to be =~ [list 1 1 5]
        } to fail_with ""
    }
}

describe "expect <actual> to not be =~ <expected>" {
    it "is not supported" {
        expect {
            expect [list 1 2 3] to not be =~ [list 1 2 3]
        } to fail_with ""
    }
}