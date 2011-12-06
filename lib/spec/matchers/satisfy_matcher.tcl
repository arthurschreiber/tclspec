# namespace eval Spec {
#     namespace eval Matchers {
#         ::Spec::Matchers proc satisfy { args } {
#             ::Spec::Matchers::SatisfyMatcher new [list -init {*}$args]
#         }

#         Class SatisfyMatcher -superclass BaseMatcher
#         SatisfyMatcher instproc init { block } {
#             my set block $block
#         }
#         SatisfyMatcher instproc matches? { actual } {
#             my instvar block
#             my set actual $actual

#             if { [llength $block] == 2 } {
#                 uplevel [Matcher set eval_level] [list set [lindex $block 0] $actual]
#                 # TODO: Add correct "return" handling here
#                 set return_value [uplevel [Matcher set eval_level] [lindex $block end]]
#                 uplevel [Matcher set eval_level] [list unset [lindex $block 0]]
#                 return [string is true $return_value]
#             } elseif { [llength $block] == 1 } {
#                 # TODO: Add correct "return" handling here
#                 uplevel $block
#             } else {

#             }
#         }
#     }
# }