source [file join [file dirname [info script]] "spec_helper.tcl"]

namespace eval test_namespace {
    proc test_method {} {
        return "accessible"
    }

    namespace export *
}

describe "Procs imported from a namespace" {
    namespace import ::test_namespace::*

    it "should be accessible inside examples" {
        expect [test_method] to equal "accessible"
    }

    describe "with a nested example group" {
        it "also should have access to the imported procs" {
            expect [test_method] to equal "accessible"
        }
    }
}
