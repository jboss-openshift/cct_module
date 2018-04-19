# Scripts unit testing

Shell scripts unit tests with [BATS](https://github.com/sstephenson/bats)

## Dependencies

* Bats
* xmllint

## Usage

Each module having a <module>/tests/bats folder can be tested with the following command:

```
$ bats <module>/tests/bats
 ✓ Test1
 ✗ Test2

2 tests, 1 failure
```
