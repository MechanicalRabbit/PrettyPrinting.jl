# Release Notes

## v0.4.2

* Fix serializing `(x -> y)(z)`.


## v0.4.1

* Enable precompilation.


## v0.4.0

* Serialize multi-line strings as triple-quoted literals.
* Require Julia ≥ 1.6.


## v0.3.2

- Fixed emitting `let` with a definition block.


## v0.3.1

- Wrap the type argument of `ref` in parentheses, if necessary.


## v0.3.0

- Formatting custom objects with `quoteof()`.
- Formatting of `Expr` objects.
- Formatting of `Set` objects.


## v0.2.1

- Minor performance improvements.


## v0.2.0

- Added `pprintln()` (thanks to tlienart).


## v0.1.0

- Initial release.
