class_name ClassWithEnumReturnTypes
extends Resource


class InnerClass:
	enum TestEnum { FOO = 111, BAR = 222 }

enum TestEnum { FOO = 1, BAR = 2 }

const NOT_AN_ENUM := 1

const X := { FOO=1, BAR=2 }


func get_enum() -> TestEnum:
	return TestEnum.FOO


# function signature with an external enum reference
func get_external_class_enum() -> CustomEnums.TestEnum:
	return CustomEnums.TestEnum.FOO


# function signature with an inner class enum reference
func get_inner_class_enum() -> InnerClass.TestEnum:
	return InnerClass.TestEnum.FOO
