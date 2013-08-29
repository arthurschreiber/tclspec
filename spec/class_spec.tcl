package require "TclOO::ext::class"

ext::class create TestClass {
    meta method defined_on_meta {} {
        return "meta"
    }

    self method defined_on_self {} {
        return "self"
    }

    method defined_on_instance {} {
        return "instance"
    }
}

ext::class create SubClass {
    superclass TestClass
}

ext::class create OtherTestClass {

}

ext::class create MultipleSuperClasses {
    superclass SubClass OtherTestClass
}

describe "ext::class" {
    specify "meta methods are available on classes" {
        expect [TestClass defined_on_meta] to equal "meta"
    }

    specify "subclasses inherit meta methods" {
        expect [SubClass defined_on_meta] to equal "meta"
    }

    specify "each class is an instance of its metaclass" {
        expect [info object class TestClass] to equal "::TestClass.Meta"
        expect [info object class SubClass] to equal "::SubClass.Meta"
    }

    specify "the metaclass of a subclass is a subclass of the superclass metaclass" {
        expect [info class superclass [info object class SubClass]] to equal [list "::TestClass.Meta" "::oo::class"]
    }

    specify "the metaclass contains all superclass metaclasses" {
        expect [info class superclass [info object class MultipleSuperClasses]] to equal [list "::SubClass.Meta" "::OtherTestClass.Meta" "::oo::class"]
    }
}
