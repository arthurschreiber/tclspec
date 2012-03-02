Feature: expect to change

  Expect the execution of a block of code to change the state of an object.

  Background:
    Given a file named "lib/counter.tcl" with:
      """
      package require nx

      nx::Class create Counter {
          :class property {count 0}

          :public class method increment {} {
              incr :count
          }
      }
      """
  
  Scenario: expect to change
    Given a file named "spec/example_spec.tcl" with:
      """
      source "lib/counter.tcl"

      describe "Counter.increment" {
          it "should increment the count" {
              expect { Counter increment } to change { Counter count } -from 0 -to 1
          }

          # deliberate failure
          it "should increment the count by 2" {
              expect { Counter increment } to change { Counter count } -by 2
          }
      }
      """
    When I run `tclspec spec/example_spec.tcl`
    Then the output should contain "1 failure"
    Then the output should contain "should have been changed by '2', but was changed by '1'"

  Scenario: expect to not change
    Given a file named "spec/example_spec.tcl" with:
      """
      source "lib/counter.tcl"

      describe "Counter.increment" {
          it "should not increment the count" {
              expect { Counter increment } to not change { Counter count }
          }
      }
      """
    When I run `tclspec spec/example_spec.tcl`
    Then the output should contain "1 failure"
    Then the output should contain "should not have changed, but did change from '0' to '1'"