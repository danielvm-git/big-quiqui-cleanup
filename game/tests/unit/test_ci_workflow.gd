# story: e05s04
extends GutTest
## The CI workflow proves the export on every run and holds no signing secret. (actionlint checks the syntax.)

var _text: String = ""


func before_each() -> void:
	var path: String = ProjectSettings.globalize_path("res://").path_join("../.github/workflows/test-build-release.yml")
	_text = FileAccess.get_file_as_string(path)


func _export_job() -> String:
	var start: int = _text.find("\n  export:")
	var end: int = _text.find("\n  release:")
	return _text.substr(start, end - start)


func test_the_workflow_keeps_its_name() -> void:
	assert_true(_text.contains("name: Test Build Release"))


func test_there_is_an_export_job_on_macos_after_the_gate() -> void:
	var job: String = _export_job()
	assert_false(job.is_empty())
	assert_true(job.contains("runs-on: macos"))
	assert_true(job.contains("needs: [test]"))
	assert_true(job.contains("bash scripts/export_ios.sh"))
	assert_true(job.contains("include-templates: true"))


func test_the_export_job_has_no_secret_and_no_write_permission() -> void:
	var job: String = _export_job()
	assert_false(job.contains("secrets."))
	assert_true(job.contains("contents: read"))


func test_the_project_is_uploaded_only_from_main() -> void:
	assert_true(_export_job().contains("github.ref == 'refs/heads/main'"))


func test_every_action_is_pinned_to_a_commit() -> void:
	var pinned: RegEx = RegEx.create_from_string("uses:\\s+[\\w./-]+@[0-9a-f]{40}")
	var count: int = 0
	for line: String in _text.split("\n"):
		if line.strip_edges().begins_with("#") or not line.contains("uses:"):
			continue
		count += 1
		assert_not_null(pinned.search(line), line)
	assert_gt(count, 3)
