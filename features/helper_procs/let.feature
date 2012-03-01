Feature: let and let!

  Use `let` to define a memoized helper method.  The value will be cached
  across multiple calls in the same example but not across examples.

  Note that `let` is lazy-evaluated: it is not evaluated until the first time
  the method it defines is invoked. You can use `let!` to force the method's
  invocation before each example.

  Scenario: use let to define memoized helper method
    Given a file named "let_spec.tcl" with:
      """
      set count 0
      describe "let" {
          let count { incr ::count }

          it "memoizes the value" {
              expect [count] to equal 1
              expect [count] to equal 1
          }

          it "is not cached across examples" {
              expect [count] to equal 2
          }
      }
      """
    When I run `tclspec let_spec.tcl`
    Then the examples should all pass

  Scenario: use let! to define a memoized helper method that is called in a before hook
    Given a file named "let_bang_spec.tcl" with:
      """
      set count 0
      describe "let!" {
          let! count {
              lappend invocation_order "let!"
              incr ::count
          }

          it "calls the helper method in a before hook" {
              lappend invocation_order "example"
              expect $invocation_order to equal [list "let!" "example"]
              expect [count] to equal 1
          }
      }
      """
    When I run `tclspec let_bang_spec.tcl`
    Then the examples should all pass