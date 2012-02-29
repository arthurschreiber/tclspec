source [file join [file dirname [info script]] "spec_helper.tcl"]

namespace eval test_namespace {
    proc test_method {} {
        return "accessible"
    }
}

namespace eval test_namespace {
    describe "An example group nested inside an namespace" {
        it "should have access to the outer namespace methods" {
            expect [test_method] to equal "accessible"
        }

        describe "with a nested example group" {
            it "also should have access to the outer namespace" {
                expect [test_method] to equal "accessible"
            }
        }
    }
}
