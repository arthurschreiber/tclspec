describe Spec::Mocks {
    describe ".setup" {
        before each {
            variable orig_space [Spec::Mocks space]
        }

        after each {
            Spec::Mocks space $orig_space
        }

        it "memoizes the mock space" {
            Spec::Mocks setup [nx::Object new { :require namespace }]

            set space [Spec::Mocks space]

            Spec::Mocks setup [nx::Object new { :require namespace }]
            expect [Spec::Mocks space] to equal $space
        }
    }

    describe ".verify" {
        it "verifies setup mock expectations" {
            set foo [double]
            $foo should_receive "bar"

            expect {
                ::Spec::Mocks verify
            } to raise_error

            $foo spec_reset
        }
    }

    describe ".teardown" {
        it "tears down existing mock expectations" {
            set foo [double]
            $foo should_receive "bar"

            Spec::Mocks teardown

            expect {
                $foo bar
            } to raise_error
        }
    }
}
