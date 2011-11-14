lappend auto_path [file join [file dirname [info script]] ".." "lib"]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]


# describe "The top level group" {
#     it "runs its children" {
#         set ::examples_run 0

#         set group [ExampleGroup describe "parent" {
#             describe "child" {
#                 it "does something" {
#                     incr ::examples_run
#                 }
#             }
#         }]

#         $group run
#         expect $::examples_run to equal 1
#     }

#     describe "with a failure" {
#         it "runs its children" {
#             set ::examples_run 0

#             set group [ExampleGroup describe "parent" {
#                 it "fails" {
#                     incr ::examples_run
#                     error "fail"
#                 }

#                 describe "child" {
#                     it "does something" {
#                         incr ::examples_run
#                     }
#                 }
#             }]

#             $group run
#             expect $::examples_run to equal 2
#         }
#     }
# }

describe "before, after, and around hooks" {
    it "runs the before alls in order" {
        set group [ExampleGroup describe]
        set ::order {}

        $group before all { lappend ::order 1 }
        $group before all { lappend ::order 2 }
        $group before all { lappend ::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::order to equal { 1 2 3 }
    }

    it "runs the before eachs in order" {
        set group [ExampleGroup describe]
        set ::order {}

        $group before each { lappend ::order 1 }
        $group before each { lappend ::order 2 }
        $group before each { lappend ::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::order to equal { 1 2 3 }
    }

    it "runs the after eachs in reverse order" {
        set group [ExampleGroup describe]
        set ::order {}

        $group after each { lappend ::order 1 }
        $group after each { lappend ::order 2 }
        $group after each { lappend ::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::order to equal { 3 2 1 }
    }

    it "runs the after alls in order" {
        set group [ExampleGroup describe]
        set ::order {}

        $group after all { lappend ::order 1 }
        $group after all { lappend ::order 2 }
        $group after all { lappend ::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::order to equal { 3 2 1 }
    }
}