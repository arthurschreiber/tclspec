lappend auto_path [file join [file dirname [info script]] ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "an example" {
    proc help {} {
        return "available"
    }

    it "has access to methods defined in its group" {
        expect [help] to equal "available"
    }
}

describe "an example" {
    it "has only access to the top-level describe method" {
        expect [llength [[describe] ancestors]] to equal 1
    }

    it "does not have access to 'it', 'example', 'before' and 'after' methods" {
        expect { it } to raise_error -message "invalid command name \"it\""
        expect { example } to raise_error -message "invalid command name \"example\""
        expect { before } to raise_error -message "invalid command name \"before\""

        # There actually is a command called after in the global namespace
        expect [namespace origin after] to equal "::after"
    }
}

describe "a helper proc" {
    proc helper {} {
        return "available"
    }

    proc helper_var_access {} {
        upvar some_value some_value
        return $some_value
    }

    proc helper_expect {} {
        expect true to be true
    }

    it "is available in examples" {
        expect [helper] to equal "available"
    }

    it "has access to expect" {
        helper_expect
    }

    it "has access to example variables through upvar" {
        set some_value "foobar"
        expect [helper_var_access] to equal "foobar"
    }

    describe "a nested helper proc" {
        proc nested_helper {} {
            return "[helper] (nested)"
        }

        it "has access to helpers of parent example groups" {
            expect [nested_helper] to equal "available (nested)"
        }
    }

    it "can't be accessed from the outside example group" {
        expect { nested_helper } to raise_error -message "invalid command name \"nested_helper\""
    }
}

describe "an example" {
    proc help {} {
        return "available"
    }

    describe "in a nested group" {
        it "has access to methods defined in its parent group" {
            expect [help] to equal "available"
        }
    }
}