package require XOTcl
namespace import xotcl::*

Class create Example
Example instproc init { description block } {
  my set description $description
  my set block $block
}

Example instproc execute { before after } {
  my instvar block

  eval $before
  eval [my set block]
  eval $after
}