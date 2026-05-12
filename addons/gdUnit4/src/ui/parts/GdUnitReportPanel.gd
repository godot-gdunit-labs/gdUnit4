@tool
class_name GdUnitReportPanel
extends Panel

@onready var report_list: Node = %report_list
@onready var message_template: RichTextLabel = %message


func clear() -> void:
	for child in report_list.get_children():
		report_list.remove_child(child)
		child.queue_free()


func show_report(reports: Array[GdUnitReport]) -> void:
	clear()
	for report in reports:
		report_list.add_child(build_report(report))


func build_report(report: GdUnitReport) -> RichTextLabel:
	var message: RichTextLabel = message_template.duplicate()
	message.push_color(GdUnitEditorColorTheme.text_color)
	message.append_text(report.message())
	message.pop()
	add_stack_trace(message, report.stack_trace())
	message.visible = true
	return message


func add_stack_trace(message: RichTextLabel, trace: GdUnitStackTrace) -> void:
	message.newline()
	for frame in trace.get_frames():
		message.push_indent(1)
		message.push_meta(frame, RichTextLabel.META_UNDERLINE_ON_HOVER, frame._source)
		message.push_color(GdUnitEditorColorTheme.text_color)
		message.append_text("at ")
		message.push_color(GdUnitEditorColorTheme.function_definition_color)
		message.append_text(frame._function)
		message.pop()
		message.append_text(" in ")
		message.pop()

		message.push_color(GdUnitEditorColorTheme.engine_type_color)
		message.append_text(frame._source.get_file())
		message.append_text(" : ")
		message.append_text(str(frame._line))
		message.pop()
		message.pop() # hint
		message.pop()
		message.newline()
	message.meta_clicked.connect(_on_meta_clicked)


func _on_meta_clicked(meta: Variant) -> void:
	print_debug("TODO: implement jump to source", "_on_meta_clicked", meta)
