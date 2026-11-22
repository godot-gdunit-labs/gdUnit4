class_name GdUnitBenchmarkSuite
extends Node
## The base class for all GdUnit benchmark suites.[br]
## Benchmark functions are prefixed with [code]bench_[/code] and return [code]void[/code].
## [codeblock]
##    extends GdUnitBenchmarkSuite
##
##    func bench_find(rounds := 10) -> void:
##        range(100).find(99)
## [/codeblock]

var __auto_free: Array = []


## Called before every benchmark, may [code]await[/code].
func setup() -> void:
	pass


## Called after every benchmark, also after errors.
func cleanup() -> void:
	pass


## Registers [param obj] to be freed after [method cleanup] and returns it.
func auto_free(obj: Variant) -> Variant:
	__auto_free.append(obj)
	return obj
