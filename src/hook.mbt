///|
/// HookType: lifecycle hook type.
pub enum HookType {
  BeforeTestRun
  AfterTestRun
  BeforeTestCase
  AfterTestCase
  BeforeTestStep
  AfterTestStep
}

///|
pub impl @json.FromJson for HookType with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError((path, "HookType::from_json: expected string"))
  }
  match s {
    "BEFORE_TEST_RUN" => BeforeTestRun
    "AFTER_TEST_RUN" => AfterTestRun
    "BEFORE_TEST_CASE" => BeforeTestCase
    "AFTER_TEST_CASE" => AfterTestCase
    "BEFORE_TEST_STEP" => BeforeTestStep
    "AFTER_TEST_STEP" => AfterTestStep
    _ =>
      raise @json.JsonDecodeError(
        (path, "HookType::from_json: expected a valid hook type string"),
      )
  }
}

///|
pub impl ToJson for HookType with to_json(self) {
  match self {
    BeforeTestRun => "BEFORE_TEST_RUN".to_json()
    AfterTestRun => "AFTER_TEST_RUN".to_json()
    BeforeTestCase => "BEFORE_TEST_CASE".to_json()
    AfterTestCase => "AFTER_TEST_CASE".to_json()
    BeforeTestStep => "BEFORE_TEST_STEP".to_json()
    AfterTestStep => "AFTER_TEST_STEP".to_json()
  }
}

///|
/// Hook: before/after hook definition.
/// Note: JSON key is "type" (not "hookType") to match upstream schema.
pub struct Hook {
  id : String
  sourceReference : SourceReference
  name : String?
  tagExpression : String?
  type_ : HookType?
}

///|
pub impl @json.FromJson for Hook with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Hook::from_json: expected object"))
  }
  let id : String = match obj.get("id") {
    Some(v) => @json.from_json(v, path=path.add_key("id"))
    None => raise @json.JsonDecodeError((path, "Hook::from_json: missing id"))
  }
  let sourceReference : SourceReference = match obj.get("sourceReference") {
    Some(v) => @json.from_json(v, path=path.add_key("sourceReference"))
    None =>
      raise @json.JsonDecodeError(
        (path, "Hook::from_json: missing sourceReference"),
      )
  }
  let name : String? = match obj.get("name") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("name")))
  }
  let tagExpression : String? = match obj.get("tagExpression") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("tagExpression")))
  }
  let type_ : HookType? = match obj.get("type") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("type")))
  }
  Hook::{ id, sourceReference, name, tagExpression, type_ }
}

///|
pub impl ToJson for Hook with to_json(self) {
  let o : Map[String, Json] = {
    "id": self.id.to_json(),
    "sourceReference": self.sourceReference.to_json(),
  }
  match self.name {
    Some(n) => o.set("name", n.to_json())
    None => ()
  }
  match self.tagExpression {
    Some(te) => o.set("tagExpression", te.to_json())
    None => ()
  }
  match self.type_ {
    Some(t) => o.set("type", t.to_json())
    None => ()
  }
  o.to_json()
}

///|
/// TestRunHookStarted: hook execution lifecycle.
pub struct TestRunHookStarted {
  id : String
  testRunStartedId : String
  hookId : String
  timestamp : Timestamp
  workerId : String?
} derive(ToJson, FromJson)

///|
/// TestRunHookFinished: hook execution finished.
pub struct TestRunHookFinished {
  testRunHookStartedId : String
  result : TestStepResult
  timestamp : Timestamp
} derive(ToJson, FromJson)

///|
test "hook type roundtrip" {
  let json = @json.parse("\"BEFORE_TEST_CASE\"") catch { _ => panic() }
  let ht : HookType = @json.from_json(json) catch { _ => panic() }
  match ht {
    BeforeTestCase => ()
    _ => panic()
  }
  assert_eq(ht.to_json().stringify(), "\"BEFORE_TEST_CASE\"")
}

///|
test "hook roundtrip" {
  let raw = "{\"id\":\"h1\",\"sourceReference\":{},\"tagExpression\":\"@smoke\"}"
  let json = @json.parse(raw) catch { _ => panic() }
  let hook : Hook = @json.from_json(json) catch { _ => panic() }
  assert_eq(hook.id, "h1")
  assert_eq(hook.tagExpression, Some("@smoke"))
  let back : Hook = @json.from_json(hook.to_json()) catch { _ => panic() }
  assert_eq(back.id, hook.id)
}

///|
test "test run hook started roundtrip" {
  let raw = "{\"id\":\"trhs1\",\"testRunStartedId\":\"trs1\",\"hookId\":\"h1\",\"timestamp\":{\"seconds\":100,\"nanos\":0}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let trhs : TestRunHookStarted = @json.from_json(json) catch { _ => panic() }
  assert_eq(trhs.id, "trhs1")
  assert_eq(trhs.hookId, "h1")
  let back : TestRunHookStarted = @json.from_json(trhs.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.testRunStartedId, "trs1")
}

///|
test "test run hook finished roundtrip" {
  let raw = "{\"testRunHookStartedId\":\"trhs1\",\"result\":{\"duration\":{\"seconds\":1,\"nanos\":0},\"status\":\"PASSED\"},\"timestamp\":{\"seconds\":101,\"nanos\":0}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let trhf : TestRunHookFinished = @json.from_json(json) catch { _ => panic() }
  assert_eq(trhf.testRunHookStartedId, "trhs1")
  match trhf.result.status {
    Passed => ()
    _ => panic()
  }
  let back : TestRunHookFinished = @json.from_json(trhf.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.testRunHookStartedId, trhf.testRunHookStartedId)
}
