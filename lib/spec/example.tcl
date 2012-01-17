namespace eval Spec {
    nx::Class create Example {
        :property example_group:required
        :property description:required
        :property block:require

        :property error_info

        :public method full_description { } {
            return "[${:example_group} full_description] ${:description}"
        }

        :public method description { } {
            set :description
        }

        :public method run { example_group_instance reporter } {
            set :example_group_instance $example_group_instance

            :start $reporter
            try {
                try {
                    :run_before_each
                    ${:example_group_instance} instance_eval ${:block}
                } on error { message error_options } {
                    :set_error $message $::errorInfo $error_options
                } finally {
                    :run_after_each
                }
            } on error { message error_options } {
                :set_error $message $::errorInfo $error_options
            }

            :finish $reporter
        }

        :public method run_before_each { } {
            ${:example_group} run_before_each ${:example_group_instance}
        }

        :public method run_after_each { } {
            ${:example_group} run_after_each ${:example_group_instance}
        }

        :public method start { reporter } {
            $reporter example_started [self]
        }

        :public method finish { reporter } {
            if { [info exists :error_message] } {
                $reporter example_failed [self]
                return false
            } else {
                $reporter example_passed [self]
                return true
            }
        }

        :public method set_error { error_message error_info error_options } {
            if { ![info exists :error_message] } {
                set :error_message $error_message
                set :error_info $error_info
                set :error_options $error_options
            }
        }
    }
}