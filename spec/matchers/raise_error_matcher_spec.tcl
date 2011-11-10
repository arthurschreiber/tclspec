lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] ".." "spec_helper.tcl"]

proc throw_some_error {} {
    return -code error -errorcode SOME_ERROR
}

describe "expect to raise_error" {
    it "passes if an error is raised" {
        expect { error "error!" } to raise_error
    }

    it "fails if nothing is raised" {
        expect {
            expect {} to raise_error
        } to fail_with "expected error with code 'NONE' but nothing was raised"
    }
}

describe "expect to raise_error -message" {
    it "passes if an error is raised with the right message" {
        expect { error "error message" } to raise_error -message "error message"
    }

    it "fails if an error is raised with the wrong message" {
        expect {
            expect { error "wrong message" } to raise_error -message "error message"
        } to fail_with "expected error with code 'NONE' and message 'error message', got error with code 'NONE' and message 'wrong message'"
    }
}

describe "expect to raise_error -code" {
    it "passes if the expected error code is raised" {
        expect {
            throw_some_error
        } to raise_error -code SOME_ERROR
    }

    it "fails if nothing is raised" {
        expect {
            expect {} to raise_error -code SOME_ERROR
        } to fail_with "expected error with code 'SOME_ERROR' but nothing was raised"
    }

    it "fails if another error code is raised" {
        expect {
            expect { throw_some_error } to raise_error -code OTHER_ERROR
        } to fail_with "expected error with code 'OTHER_ERROR', got error with code 'SOME_ERROR' and message ''"
    }
}

describe "expect to not raise_error -code" {
    it "passes if nothing is raised" {
        expect { } to not raise_error -code SOME_ERROR
    }

    it "passes if another error is raised" {
        expect { throw_some_error } to not raise_error -code OTHER_ERROR
    }

    it "fails if the passed error code is raised" {
        expect {
            expect { throw_some_error } to not raise_error -code SOME_ERROR
        } to fail_with "expected no error with code 'SOME_ERROR', got error with code 'SOME_ERROR' and message ''"
    }
}
