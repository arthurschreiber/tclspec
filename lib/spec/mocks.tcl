namespace eval Spec {
    namespace eval Mocks {
        namespace path ::Spec
    }

    Class create Mocks
    Mocks proc setup { host_namespace } {
        
    }

    Mocks proc space {} {
        if { ![my exists space] } {
            my set space [::Spec::Mocks::Space new]
        }
        my set space
    }

    Mocks proc verify {} {
        [my space] verify_all
    }

    Mocks proc teardown {} {
        [my space] reset_all
    }
}

source [file join [file dirname [info script]] "mocks/mock.tcl"]
source [file join [file dirname [info script]] "mocks/space.tcl"]
