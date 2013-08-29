package require "TclOO"
package require "TclOO::ext::autorelease_pool" "1.0"

package provide "TclOO::ext::reference_countable" "1.0"

# == Reference Counting Policy ==
#
# === Basic Reference Counting Rules ===
#
# * You own any object you create:
#
#   You can create a new object using the `new` class method of the
#   respective class.
#
# * You can take ownership of an object using `retain`:
#
#   Objects returned by a method call are usually guaranteed to remain
#   valid for the whole duration of the calling function/method scope.
#
#   `retain` should be used in the following situations:
#
#     1. In implementations of setter methods to take ownership of an object
#        that is going to be stored in an instance variable.
#     2. To prevent an object from getting released due to some other operation.
#
# * When you no longer need an object, you must release it:
#
#   Object ownership can be given up by calling the `release` or
#   `autorelease` method on it.
#
# * You must not release an object that you do not own:
#
#   Releasing objects you do not own will lead to objects being destroyed
#   prematurely, causing program crashes.
#
# ==== Example ====
#
# Here is a simple example to illustrate the previous rules:
#
#   set person [Person new]
#
#   #...
#
#   set name [$person name]
#
#   #...
#
#   $person release
#
# The `person` object is created using the `new` method on the `Person` class,
# so the `release` method has to be called on it when it is no longer used.
#
# The `name` is retrieved using an accessor method (and might not even be an
# object), so no call to `release` is needed here.
#
# ==== Using autorelease for deferred releases ====
#
# Use `autorelease` when you need to release an object at a "later" time -
# usually when you return an object from a method. For example, a `full_name`
# method could be implemented like this:
#
#   method full_name {} {
#       my variable first_name last_name
#       return [[FullName new $first_name $last_name] autorelease]
#   }
#
# You own the object created by the call to `new`, so the object must also be
# released by you. But if you use `release`, the object will be released before
# it gets returned (and `full_name` would return an invalid object).
# By using `autorelease`, we signal that we want to give up ownership of the
# object, but allow the caller of this method to use the object before it is
# destroyed.
oo::class create ReferenceCountable {
    unexport destroy

    method retain {} {
        my variable __reference_count__
        if { ![info exists __reference_count__] } {
            set __reference_count__ 1
        }

        incr __reference_count__ 1
        return [self]
    }

    method release {} {
        my variable __reference_count__
        if { ![info exists __reference_count__] } {
            set __reference_count__ 1
        }

        incr __reference_count__ -1
        if { $__reference_count__ == 0 } {
            my destroy
        }
    }

    method autorelease {} {
        my variable __reference_count__
        if { ![info exists __reference_count__] } {
            set __reference_count__ 1
        }

        AutoreleasePool add_object [self]

        return [self]
    }
}
