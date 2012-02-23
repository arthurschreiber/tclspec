lappend auto_path [file join [file dirname [info script]] ".."]
package require spec/autorun

source [file join [file dirname [info script]] "spec_helper.tcl"]

namespace eval ::Helper {}

describe "The top level group" {
    before each {
        set ::Helper::examples_run 0
    }

    after each {
        unset ::Helper::examples_run
    }

    it "runs its children" {
        set group [::Spec::ExampleGroup describe "parent" {
            describe "child" {
                it "does something" {
                    incr ::Helper::examples_run
                }
            }
        }]

        expect [$group run [NullObject new]] to be true
        expect $::Helper::examples_run to equal 1
    }

    describe "with a failure" {
        it "runs its children" {
            set group [::Spec::ExampleGroup describe "parent" {
                it "fails" {
                    incr ::Helper::examples_run
                    error "fail"
                }

                describe "child" {
                    it "does something" {
                        incr ::Helper::examples_run
                    }
                }
            }]

            expect [$group run [NullObject new]] to be false
            expect $::Helper::examples_run to equal 2
        }
    }
}

describe "child" {
    it "is known by its parent" {
        set parent [::Spec::ExampleGroup describe]
        set child [$parent describe]
        expect [$parent children] to equal [list $child]
    }

    it "is not registered in the world" {
        set world [::Spec::World new]
        set parent [::Spec::ExampleGroup describe]

        $world register $parent

        $parent describe

        expect [$world example_groups] to equal [list $parent]
    }
}

describe "before, after, and around hooks" {
    before each {
        set ::Helper::order {}
    }

    after each {
        unset ::Helper::order
    }

    it "runs the before alls in order" {
        set group [::Spec::ExampleGroup describe]

        $group before all { lappend ::Helper::order 1 }
        $group before all { lappend ::Helper::order 2 }
        $group before all { lappend ::Helper::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::Helper::order to equal [list 1 2 3]
    }

    it "runs the before eachs in order" {
        set group [::Spec::ExampleGroup describe]

        $group before each { lappend ::Helper::order 1 }
        $group before each { lappend ::Helper::order 2 }
        $group before each { lappend ::Helper::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::Helper::order to equal [list 1 2 3]
    }

    it "runs the after eachs in reverse order" {
        set group [::Spec::ExampleGroup describe]

        $group after each { lappend ::Helper::order 1 }
        $group after each { lappend ::Helper::order 2 }
        $group after each { lappend ::Helper::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::Helper::order to equal [list 3 2 1]
    }

    it "runs the after alls in order" {
        set group [::Spec::ExampleGroup describe]

        $group after all { lappend ::Helper::order 1 }
        $group after all { lappend ::Helper::order 2 }
        $group after all { lappend ::Helper::order 3 }
        $group example "example" { }

        $group run [NullObject new]

        expect $::Helper::order to equal [list 3 2 1]
    }
}

describe "adding examples" {
    it "allows adding examples using 'it'" {
        set group [::Spec::ExampleGroup describe]
        $group it "should do something" { }
        expect [llength [$group examples]] to equal 1
    }

    it "exposes all added examples using 'examples'" {
        set group [::Spec::ExampleGroup describe]
        $group it "should do something 1" { }
        $group it "should do something 2" { }
        $group it "should do something 3" { }
        expect [llength [$group examples]] to equal 3
    }

    it "maintains the example order" {
        set group [::Spec::ExampleGroup describe]
        $group it "should 1" { }
        $group it "should 2" { }
        $group it "should 3" { }

        expect [[lindex [$group examples] 0] description] to equal "should 1"
        expect [[lindex [$group examples] 1] description] to equal "should 2"
        expect [[lindex [$group examples] 2] description] to equal "should 3"
    }
}

describe "how instance variables are inherited" {
    before all {
        set before_all_top_level "before_all_top_level"
    }

    before each {
        set before_each_top_level "before_each_top_level"
    }

    it "can access a before each instvar at the same level" {
        expect $before_each_top_level to equal "before_each_top_level"
    }

    it "can access a before all instvar at the same level" {
        expect $before_all_top_level to equal "before_all_top_level"
    }

    describe "but now I am nested" {
        it "can access a parent example groups before each ivar at a nested level" {
            expect $before_each_top_level to equal "before_each_top_level"
        }

        it "can access a parent example groups before all ivar at a nested level" {
            expect $before_all_top_level to equal "before_all_top_level"
        }

        it "changes to before all ivars from within an example do not persist outside the current describe" {
            set before_all_top_level "i've been changed"
        }

        describe "accessing a before_all ivar that was changed in a parent example_group" {
            it "does not have access to the modified version" {
                expect $before_all_top_level to equal "before_all_top_level"
            }
        }
    }
}

describe "variables are not shared across examples" {
    it "(first example)" {
        set a 1
        expect [info exists b] to be false
    }

    it "(second example)" {
        set b 1
        expect [info exists a] to be false
    }
}

describe "ancestors" {
    it "returns a list of the current and the parent example groups" {
        set top [::Spec::ExampleGroup describe "top"]
        set middle [$top describe "middle"]
        set bottom [$middle describe "bottom"]

        expect [$bottom ancestors] should equal [list $bottom $middle $top]
    }
}

describe "running the examples" {
    it "returns true if all examples pass" {
        set group [::Spec::ExampleGroup describe "group" {
            example "ex 1" {
                expect 1 to equal 1
            }

            example "ex 2" {
                expect 1 to equal 1
            }
        }]

        expect [$group run [NullObject new]] to be true
    }

    it "returns false if any of the examples fail" {
        set group [::Spec::ExampleGroup describe "group" {
            example "ex 1" {
                expect 1 to equal 1
            }

            example "ex 2" {
                expect 1 to equal 2
            }
        }]

        expect [$group run [NullObject new]] to be false
    }

    it "runs all examples, regardless of failing ones" {
        set group [::Spec::ExampleGroup describe "group" {
            example "ex 1" {
                expect 1 to equal 2
            }

            example "ex 2" {
                expect 1 to equal 1
            }
        }]

        foreach example [$group examples] {
            $example should_receive "run" -and_return [list false]
        }

        expect [$group run [NullObject new]] to be false
    }
}