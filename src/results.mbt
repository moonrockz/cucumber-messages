///|
/// TestStepResultStatus: status of a step.
pub enum TestStepResultStatus {
  Unknown
  Passed
  Skipped
  Pending
  Undefined
  Ambiguous
  Failed
}

///|
pub impl @json.FromJson for TestStepResultStatus with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "TestStepResultStatus::from_json: expected string"),
    )
  }
  match s {
    "UNKNOWN" => Unknown
    "PASSED" => Passed
    "SKIPPED" => Skipped
    "PENDING" => Pending
    "UNDEFINED" => Undefined
    "AMBIGUOUS" => Ambiguous
    "FAILED" => Failed
    _ =>
      raise @json.JsonDecodeError(
        (
          path, "TestStepResultStatus::from_json: expected one of UNKNOWN, PASSED, SKIPPED, PENDING, UNDEFINED, AMBIGUOUS, FAILED",
        ),
      )
  }
}

///|
pub impl ToJson for TestStepResultStatus with to_json(self) {
  match self {
    Unknown => "UNKNOWN".to_json()
    Passed => "PASSED".to_json()
    Skipped => "SKIPPED".to_json()
    Pending => "PENDING".to_json()
    Undefined => "UNDEFINED".to_json()
    Ambiguous => "AMBIGUOUS".to_json()
    Failed => "FAILED".to_json()
  }
}

///|
/// TestStepResult: result of a step (duration, status, optional message and exception).
pub struct TestStepResult {
  duration : Duration
  status : TestStepResultStatus
  message : String?
  exception : Exception?
} derive(ToJson, FromJson)

///|
test "test step result status roundtrip all values" {
  let statuses = [
    "UNKNOWN", "PASSED", "SKIPPED", "PENDING", "UNDEFINED", "AMBIGUOUS", "FAILED",
  ]
  for s in statuses {
    let json = @json.parse("\"" + s + "\"") catch { _ => panic() }
    let status : TestStepResultStatus = @json.from_json(json) catch {
      _ => panic()
    }
    assert_eq(status.to_json().stringify(), "\"" + s + "\"")
  }
}
