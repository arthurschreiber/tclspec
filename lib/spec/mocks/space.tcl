namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec

        Class create Space
        Space instproc init {} {
            my set mocks [list]
        }

        Space instproc empty? {} {
            expr { [llength [my set mocks]] == 0 }
        }

        Space instproc add { mock } {
            my lappend mocks $mock
        }

        Space instproc verify_all {} {
            foreach mock [my set mocks] {
                $mock spec_verify
            }
        }

        Space instproc reset {} {
            foreach mock [my set mocks] {
                $mock spec_reset
            }
        }

        Space instproc reset_all {} {
            my reset
            my set mocks [list]
        }
    }
}