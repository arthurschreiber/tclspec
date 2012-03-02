Feature: "be" matchers

  There are two "be" matchers:

      expect $value to be true # passes of $value is truthy (true, yes, 1, ...)
      expect $value to be false # passes of $value is falsy (false, no, 0, ...)

  Scenario: be_true matcher
    Given a file named "be_true_spec.tcl" with:
      """
      describe "be true matcher" {
          it "should pass if given true" {
              expect true to be true
              expect tru to be true
              expect tr to be true
              expect t to be true
          }

          it "should pass if given 1" {
              expect 1 to be true
          }

          it "should pass if given yes" {
              expect yes to be true
              expect ye to be true
              expect y to be true
          }

          it "should pass if given on" {
              expect on to be true
          }

          # deliberate failures
          it "should not pass if given only an o" {
              expect o to be true
          }

          it "should not pass if given false" {
              expect false to be true
          }

          it "should not pass if given a number" {
              expect 20 to be true
          }

          it "should not pass if given a random string" {
              expect "random string" to be true
          }

          it "should not pass if given true" {
              expect true to not be true
          }
      }
      """
    When I run `tclspec be_true_spec.tcl`
    Then the output should contain all of these:
      | 9 examples, 5 failures              |
      | Expected 'o' to be true             |
      | Expected 'false' to be true         |
      | Expected '20' to be true            |
      | Expected 'random string' to be true |
      | Expected 'true' to not be true      |

  Scenario: be_false matcher
    Given a file named "be_false_spec.tcl" with:
      """
      describe "be false matcher" {
          it "should pass if given false" {
              expect false to be false
              expect fals to be false
              expect fal to be false
              expect fa to be false
              expect f to be false
          }

          it "should pass if given 1" {
              expect 0 to be false
          }

          it "should pass if given yes" {
              expect no to be false
              expect n to be false
          }

          it "should pass if given on" {
              expect off to be false
              expect of to be false
          }

          # deliberate failures
          it "should not pass if given only an o" {
              expect o to be false
          }

          it "should not pass if given false" {
              expect true to be false
          }

          it "should not pass if given a number" {
              expect 20 to be false
          }

          it "should not pass if given a random string" {
              expect "random string" to be false
          }

          it "should not pass if given false" {
              expect false to not be false
          }
      }
      """
    When I run `tclspec be_false_spec.tcl`
    Then the output should contain all of these:
      | 9 examples, 5 failures               |
      | Expected 'o' to be false             |
      | Expected 'true' to be false          |
      | Expected '20' to be false            |
      | Expected 'random string' to be false |
      | Expected 'false' to not be false     |