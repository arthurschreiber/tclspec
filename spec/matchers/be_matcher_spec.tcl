lappend auto_path [file join [file dirname [info script]] ".." ".." "lib"]
package require spec/autorun

describe "BeTrueMatcher" {
    before each {
        set matcher [ Spec::Matchers::BeTrueMatcher new ]
    }

    it "matches when actual is a truthy value" {
        expect [ $matcher matches? true ] to be true
        expect [ $matcher matches? tru ] to be true
        expect [ $matcher matches? tr ] to be true
        expect [ $matcher matches? t ] to be true

        expect [ $matcher matches? on ] to be true

        expect [ $matcher matches? yes ] to be true
        expect [ $matcher matches? ye ] to be true
        expect [ $matcher matches? y ] to be true

        expect [ $matcher matches? 1 ] to be true
    }

    it "does not matches when actual is not a truthy value" {
        expect [ $matcher does_not_match? "test" ] to be true
        expect [ $matcher does_not_match? 123 ] to be true
    }

    it "provides actual on #positive_failure_message" {
        $matcher matches? 2
        expect [ $matcher positive_failure_message ] to equal "Expected <2> to be true"
    }

    it "provides actual on #negative_failure_message" {
        $matcher does_not_match? 2
        expect [ $matcher negative_failure_message ] to equal "Expected <2> to not be true"
    }
}

describe "BeFalseMatcher" {
    before each {
        set matcher [ Spec::Matchers::BeFalseMatcher new ]
    }

    it "matches when actual is a falsy value" {
        expect [ $matcher matches? false ] to be true
        expect [ $matcher matches? fals ] to be true
        expect [ $matcher matches? fal ] to be true
        expect [ $matcher matches? fa ] to be true
        expect [ $matcher matches? f ] to be true

        expect [ $matcher matches? off ] to be true
        expect [ $matcher matches? of ] to be true

        expect [ $matcher matches? no ] to be true
        expect [ $matcher matches? n ] to be true

        expect [ $matcher matches? 0 ] to be true
    }

    it "does not matches when actual is not a falsy value" {
        expect [ $matcher does_not_match? "test" ] to be true
        expect [ $matcher does_not_match? 123 ] to be true
    }

    it "provides actual on #positive_failure_message" {
        $matcher matches? 2
        expect [ $matcher positive_failure_message ] to equal "Expected <2> to be false"
    }

    it "provides actual on #negative_failure_message" {
        $matcher does_not_match? 2
        expect [ $matcher negative_failure_message ] to equal "Expected <2> to not be false"
    }
}

describe "BeComparedToMatcher, with < as operator" {
    before each {
        set matcher [ Spec::Matchers::BeComparedToMatcher new 10 "<" ]
    }

    it "matches when actual is < expected" {
        expect [ $matcher matches? 3 ] to be true
    }

    it "does not match when actual is not < expected" {
        expect [ $matcher does_not_match? 11 ] to be true
    }
}