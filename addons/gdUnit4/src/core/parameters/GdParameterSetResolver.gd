@abstract class_name GdParameterSetResolver
extends RefCounted

const EMPTY_SET: Array[Array] = []


@abstract func get_parameters(instance: Node, index: int) -> Array


@abstract func get_max_index() -> int
