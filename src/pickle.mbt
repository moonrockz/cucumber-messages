///|
/// PickleTableCell: a cell in a pickle data table.
pub(all) struct PickleTableCell {
  value : String
} derive(ToJson, FromJson)

///|
/// PickleTableRow: a row in a pickle data table.
pub(all) struct PickleTableRow {
  cells : Array[PickleTableCell]
} derive(ToJson)

///|
pub impl @json.FromJson for PickleTableRow with fn from_json(json, path) {
  let obj = expect_object(json, path, "PickleTableRow")
  PickleTableRow::{ cells: non_empty_array_field(obj, "cells", path), }
}

///|
/// PickleTable: a data table in a pickle step.
pub(all) struct PickleTable {
  /// 1 if declared before the doc string, 2 if declared after.
  argumentIndex : Int?
  rows : Array[PickleTableRow]
} derive(ToJson)

///|
pub impl @json.FromJson for PickleTable with fn from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "PickleTable::from_json: expected object"),
    )
  }
  PickleTable::{
    argumentIndex: argument_index_field(obj, path),
    rows: required_field(obj, "rows", path),
  }
}

///|
/// PickleDocString: a doc string in a pickle step.
pub(all) struct PickleDocString {
  /// 1 if declared before the data table, 2 if declared after.
  argumentIndex : Int?
  mediaType : String?
  content : String
} derive(ToJson)

///|
pub impl @json.FromJson for PickleDocString with fn from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "PickleDocString::from_json: expected object"),
    )
  }
  PickleDocString::{
    argumentIndex: argument_index_field(obj, path),
    mediaType: optional_field(obj, "mediaType", path),
    content: required_field(obj, "content", path),
  }
}

///|
/// PickleStepArgument: argument for a pickle step.
pub(all) struct PickleStepArgument {
  docString : PickleDocString?
  dataTable : PickleTable?
} derive(ToJson, FromJson)

///|
/// PickleStepType: type of a pickle step.
pub(all) enum PickleStepType {
  Unknown
  Context
  Action
  Outcome
}

///|
pub impl @json.FromJson for PickleStepType with fn from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "PickleStepType::from_json: expected string"),
    )
  }
  match s {
    "Unknown" => Unknown
    "Context" => Context
    "Action" => Action
    "Outcome" => Outcome
    _ =>
      raise @json.JsonDecodeError(
        (path, "PickleStepType::from_json: expected a valid pickle step type"),
      )
  }
}

///|
pub impl ToJson for PickleStepType with fn to_json(self) {
  match self {
    Unknown => "Unknown".to_json()
    Context => "Context".to_json()
    Action => "Action".to_json()
    Outcome => "Outcome".to_json()
  }
}

///|
/// PickleStep: a step in a pickle.
/// Note: JSON key is "type" (not "pickleStepType") to match upstream schema.
pub(all) struct PickleStep {
  id : String
  text : String
  astNodeIds : Array[String]
  type_ : PickleStepType?
  argument : PickleStepArgument?
}

///|
pub impl @json.FromJson for PickleStep with fn from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "PickleStep::from_json: expected object"),
    )
  }
  let id : String = match obj.get("id") {
    Some(v) => @json.from_json(v, path=path.add_key("id"))
    None =>
      raise @json.JsonDecodeError((path, "PickleStep::from_json: missing id"))
  }
  let text : String = match obj.get("text") {
    Some(v) => @json.from_json(v, path=path.add_key("text"))
    None =>
      raise @json.JsonDecodeError((path, "PickleStep::from_json: missing text"))
  }
  let astNodeIds : Array[String] = non_empty_array_field(
    obj, "astNodeIds", path,
  )
  let type_ : PickleStepType? = match obj.get("type") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("type")))
  }
  let argument : PickleStepArgument? = match obj.get("argument") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("argument")))
  }
  PickleStep::{ id, text, astNodeIds, type_, argument, }
}

///|
pub impl ToJson for PickleStep with fn to_json(self) {
  let o : Map[String, Json] = {
    "id": self.id.to_json(),
    "text": self.text.to_json(),
    "astNodeIds": self.astNodeIds.to_json(),
  }
  match self.type_ {
    Some(t) => o.set("type", t.to_json())
    None => ()
  }
  match self.argument {
    Some(a) => o.set("argument", a.to_json())
    None => ()
  }
  o.to_json()
}

///|
/// PickleTag: a tag in a pickle.
pub(all) struct PickleTag {
  name : String
  astNodeId : String
} derive(ToJson, FromJson)

///|
/// Pickle: compiled test case from a scenario.
pub(all) struct Pickle {
  id : String
  uri : String
  name : String
  language : String
  steps : Array[PickleStep]
  tags : Array[PickleTag]
  astNodeIds : Array[String]
  location : Location?
} derive(ToJson)

///|
pub impl @json.FromJson for Pickle with fn from_json(json, path) {
  let obj = expect_object(json, path, "Pickle")
  Pickle::{
    id: required_field(obj, "id", path),
    uri: required_field(obj, "uri", path),
    name: required_field(obj, "name", path),
    language: required_field(obj, "language", path),
    steps: required_field(obj, "steps", path),
    tags: required_field(obj, "tags", path),
    astNodeIds: non_empty_array_field(obj, "astNodeIds", path),
    location: optional_field(obj, "location", path),
  }
}

///|
test "pickle step type roundtrip" {
  let json = @json.parse("\"Action\"") catch { _ => panic() }
  let pt : PickleStepType = @json.from_json(json) catch { _ => panic() }
  match pt {
    Action => ()
    _ => panic()
  }
  assert_eq(pt.to_json().stringify(), "\"Action\"")
}

///|
test "pickle roundtrip" {
  let raw = "{\"id\":\"p1\",\"uri\":\"test.feature\",\"name\":\"P\",\"language\":\"en\",\"steps\":[{\"id\":\"ps1\",\"text\":\"a step\",\"astNodeIds\":[\"s1\"]}],\"tags\":[{\"name\":\"@smoke\",\"astNodeId\":\"t1\"}],\"astNodeIds\":[\"sc1\"]}"
  let json = @json.parse(raw) catch { _ => panic() }
  let pickle : Pickle = @json.from_json(json) catch { _ => panic() }
  assert_eq(pickle.id, "p1")
  assert_eq(pickle.name, "P")
  assert_eq(pickle.steps.length(), 1)
  assert_eq(pickle.steps[0].text, "a step")
  assert_eq(pickle.tags.length(), 1)
  assert_eq(pickle.tags[0].name, "@smoke")
  let back : Pickle = @json.from_json(pickle.to_json()) catch { _ => panic() }
  assert_eq(back.id, pickle.id)
}

///|
test "pickle step argument keeps argumentIndex" {
  let raw = "{\"docString\":{\"argumentIndex\":2,\"content\":\"text\"},\"dataTable\":{\"argumentIndex\":1,\"rows\":[]}}"
  let arg : PickleStepArgument = @json.from_json(@json.parse(raw))
  assert_eq(arg.docString.map(d => d.argumentIndex), Some(Some(2)))
  assert_eq(arg.dataTable.map(t => t.argumentIndex), Some(Some(1)))
  assert_eq(arg.to_json(), @json.parse(raw))
}

///|
test "argumentIndex outside 1..2 is rejected" {
  for
    raw in [
      "{\"argumentIndex\":0,\"rows\":[]}", "{\"argumentIndex\":3,\"rows\":[]}",
    ] {
    let t : PickleTable? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(t is None, msg="accepted \{raw}")
  }
  for
    raw in [
      "{\"argumentIndex\":0,\"content\":\"c\"}", "{\"argumentIndex\":3,\"content\":\"c\"}",
    ] {
    let d : PickleDocString? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(d is None, msg="accepted \{raw}")
  }
  let t : PickleTable = @json.from_json(@json.parse("{\"rows\":[]}"))
  assert_eq(t.argumentIndex, None)
  let d : PickleDocString = @json.from_json(
    @json.parse(
      "{\"argumentIndex\":2,\"mediaType\":\"text/plain\",\"content\":\"c\"}",
    ),
  )
  assert_eq(d.argumentIndex, Some(2))
  assert_eq(d.mediaType, Some("text/plain"))
}
