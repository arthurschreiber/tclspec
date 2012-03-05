# TclSpec

Behaviour Driven Development for Tcl

## Overview

TclSpec is a Behaviour Driven Development (BDD) Framework for the Tcl language.

It is based on [RSpec](https://www.relishapp.com/rspec), a BDD Framework for Ruby.

## Prerequisites

 * Tcl 8.5 or higher
 * [Next Scripting Framework](http://next-scripting.org/) 2.0b3 or higher

## Installation

Put the tclspec folder into one of the folders denoted in your Tcl's $auto_path.

## Basic Usage

TclSpec allows you to describe the behaviour of your code using a structure of
`describe` and `it` blocks.

### Basic Structure

```tcl
describe Order {
    it "sums the prices of its line items" {
        set order [Order new]
        $order add_entry [LineItem new -item [Item new -price "1.11"]]
        $order add_entry [LineItem new -item [Item new -price "2.22" -quantity 2]]

        expect [$order total] to equal 5.55
    }
}
```

### Nested Groups

Groups can be nested using `example` or `context` keywords:

```tcl
describe Order {
    context "with no items" {
        it "behaves one way" {
            # ...
        }
    }

    context "with one item" {
        it "behaves another way" {
            # ...
        }
    }
}
```

## Matchers

TclSpec comes with a list of built in matchers that you can use to express
expected outcomes inside your specifications.

### Equivalence

```tcl
expect $actual to equal $expected
```

### Comparisons

```tcl
expect $actual to be >  $expected
expect $actual to be >= $expected
expect $actual to be <= $expected
expect $actual to be <  $expected
expect $actual to be_within $delta of $expected
```

### Truthiness

```tcl
expect $actual to be true
expect $actual to be false
```

### Expecting Errors

```tcl
expect { ... } to raise_error
expect { ... } to raise_error -code SomeErrorCode
expect { ... } to raise_error -message "Some error message"
expect { ... } to raise_error -code SomeErrorCode -message "Some error message
```

## The `tclspec` Command

In the `bin` folder, you can find the `tclspec` executable, which is used to
run tclspec. Calling `tclspec` without any arguments will execute all spec files
located in the spec folder in the current working directory. Additionally, you
can either pass individual files or folders to run.