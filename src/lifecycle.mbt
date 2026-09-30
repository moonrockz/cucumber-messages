///|
/// TestRunStarted: test run lifecycle.
pub struct TestRunStarted {
  timestamp : Timestamp
  id : String?
} derive(ToJson, FromJson)

///|
/// TestRunFinished: test run finished (success, timestamp, optional message, exception, testRunStartedId).
pub struct TestRunFinished {
  message : String?
  success : Bool
  timestamp : Timestamp
  exception : Exception?
  testRunStartedId : String?
} derive(ToJson, FromJson)

///|
/// TestCaseStarted: test case attempt started.
pub struct TestCaseStarted {
  attempt : Int
  id : String
  testCaseId : String
  workerId : String?
  timestamp : Timestamp
} derive(ToJson)

///|
pub impl @json.FromJson for TestCaseStarted with fn from_json(json, path) {
  let obj = expect_object(json, path, "TestCaseStarted")
  TestCaseStarted::{
    attempt: int_field_min(obj, "attempt", path, min=0),
    id: required_field(obj, "id", path),
    testCaseId: required_field(obj, "testCaseId", path),
    workerId: optional_field(obj, "workerId", path),
    timestamp: required_field(obj, "timestamp", path),
  }
}

///|
/// TestCaseFinished: test case attempt finished.
pub struct TestCaseFinished {
  testCaseStartedId : String
  timestamp : Timestamp
  willBeRetried : Bool
} derive(ToJson, FromJson)

///|
/// TestStepStarted: step lifecycle.
pub struct TestStepStarted {
  testCaseStartedId : String
  testStepId : String
  timestamp : Timestamp
} derive(ToJson, FromJson)

///|
/// TestStepFinished: step finished with result.
pub struct TestStepFinished {
  testCaseStartedId : String
  testStepId : String
  testStepResult : TestStepResult
  timestamp : Timestamp
} derive(ToJson, FromJson)

///|
/// UndefinedParameterType: reports undefined parameter type.
pub struct UndefinedParameterType {
  expression : String
  name : String
} derive(ToJson, FromJson)
