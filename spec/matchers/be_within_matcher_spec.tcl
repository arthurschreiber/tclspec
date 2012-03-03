source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

describe "expect <actual> to be within <delta> of <expected>" {
    it "passes when actual == expected" {
        expect 5.0 to be_within 0.5 of 5.0
    }

    it "passes when actual < (expected + delta)" {
        expect 5.49 to be_within 0.5 of 5.0
    }

    it "passes when actual > (expected - delta)" {
        expect 4.51 to be_within 0.5 of 5.0
    }

    it "fails when actual == (expected - delta)" {
        expect {
            expect 4.5 to be_within 0.5 of 5.0
        } to fail_with "expected '4.5' to be within '0.5' of '5.0'"
    }

    it "fails when actual < (expected - delta)" {
        expect {
            expect 4.49 to be_within 0.5 of 5.0
        } to fail_with "expected '4.49' to be within '0.5' of '5.0'"
    }

    it "fails when actual == (expected + delta)" {
        expect {
            expect 5.5 to be_within 0.5 of 5.0
        } to fail_with "expected '5.5' to be within '0.5' of '5.0'"
    }

    it "fails when actual > (expected + delta)" {
        expect {
            expect 5.51 to be_within 0.5 of 5.0
        } to fail_with "expected '5.51' to be within '0.5' of '5.0'"
    }
}

describe "expect <actual> to not be within <delta> of <expected>" {
    it "passes when actual == (expected - delta)" {
        expect 4.5 to not be_within 0.5 of 5.0
    }

    it "passes when actual < (expected - delta)" {
        expect 4.49 to not be_within 0.5 of 5.0
    }

    it "passes when actual == (expected + delta)" {
        expect 5.5 to not be_within 0.5 of 5.0
    }

    it "passes when actual > (expected + delta)" {
        expect 5.51 to not be_within 0.5 of 5.0
    }

    it "fails when actual == expected" {
        expect {
            expect 5.0 to not be_within 0.5 of 5.0
        } to fail_with "expected '5.0' to not be within '0.5' of '5.0'"
    }

    it "fails when actual < (expected + delta)" {
        expect {
            expect 5.49 to not be_within 0.5 of 5.0
        } to fail_with "expected '5.49' to not be within '0.5' of '5.0'"
    }

    it "fails when actual > (expected - delta)" {
        expect {
            expect 4.51 to not be_within 0.5 of 5.0
        } to fail_with "expected '4.51' to not be within '0.5' of '5.0'"
    }
}