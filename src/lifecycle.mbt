///|
/// TestRunStarted: test run lifecycle.
#derive(ToJson, FromJson)
pub struct TestRunStarted {
  timestamp : Timestamp
  id : String?
}

///|
/// TestRunFinished: test run finished (success, timestamp, optional message, exception, testRunStartedId).
#derive(ToJson, FromJson)
pub struct TestRunFinished {
  message : String?
  success : Bool
  timestamp : Timestamp
  exception : Exception?
  testRunStartedId : String?
}

///|
/// TestCaseStarted: test case attempt started.
#derive(ToJson)
pub struct TestCaseStarted {
  attempt : Int32
  id : String
  testCaseId : String
  workerId : String?
  timestamp : Timestamp
}

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
#derive(ToJson, FromJson)
pub struct TestCaseFinished {
  testCaseStartedId : String
  timestamp : Timestamp
  willBeRetried : Bool
}

///|
/// TestStepStarted: step lifecycle.
#derive(ToJson, FromJson)
pub struct TestStepStarted {
  testCaseStartedId : String
  testStepId : String
  timestamp : Timestamp
}

///|
/// TestStepFinished: step finished with result.
#derive(ToJson, FromJson)
pub struct TestStepFinished {
  testCaseStartedId : String
  testStepId : String
  testStepResult : TestStepResult
  timestamp : Timestamp
}

///|
/// UndefinedParameterType: reports undefined parameter type.
#derive(ToJson, FromJson)
pub struct UndefinedParameterType {
  expression : String
  name : String
}
