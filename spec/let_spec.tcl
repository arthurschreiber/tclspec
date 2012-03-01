source [file join [file dirname [info script]] "spec_helper.tcl"]

describe "let" {
    before all {
        set ::count 0
    }

    let "count" {
        incr ::count
    }

    it "memoizes the return value between calls" {
        expect [count] to equal 1
        expect [count] to equal 1
    }

    it "is not cached between examples" {
        expect [count] to equal 2
    }

    it "(do nothing)" {
        # do nothing
    }

    it "is evaluated lazily" {
        expect [count] to equal 3
    }
}

describe "let!" {
    before all {
        set ::count 0
        set ::invocation_order {}
    }

    let! "count" {
        lappend ::invocation_order "let!"
        incr ::count
    }

    it "memoizes the return value between calls" {
        expect [count] to equal 1
        expect [count] to equal 1
    }

    it "is not cached between examples" {
        expect [count] to equal 2
    }

    it "(do nothing)" {
        # do nothing
    }

    it "is not evaluated lazily" {
        expect [count] to equal 4
    }
}