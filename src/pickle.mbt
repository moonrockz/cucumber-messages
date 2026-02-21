///|
/// PickleTableCell: a cell in a pickle data table.
pub struct PickleTableCell {
  value : String
} derive(ToJson, FromJson)

///|
/// PickleTableRow: a row in a pickle data table.
pub struct PickleTableRow {
  cells : Array[PickleTableCell]
} derive(ToJson, FromJson)

///|
/// PickleTable: a data table in a pickle step.
pub struct PickleTable {
  rows : Array[PickleTableRow]
} derive(ToJson, FromJson)

///|
/// PickleDocString: a doc string in a pickle step.
pub struct PickleDocString {
  content : String
  mediaType : String?
} derive(ToJson, FromJson)

///|
/// PickleStepArgument: argument for a pickle step.
pub struct PickleStepArgument {
  docString : PickleDocString?
  dataTable : PickleTable?
} derive(ToJson, FromJson)

///|
/// PickleStepType: type of a pickle step.
pub enum PickleStepType {
  Unknown
  Context
  Action
  Outcome
}

///|
pub impl @json.FromJson for PickleStepType with from_json(json, path) {
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
pub impl ToJson for PickleStepType with to_json(self) {
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
pub struct PickleStep {
  id : String
  text : String
  astNodeIds : Array[String]
  type_ : PickleStepType?
  argument : PickleStepArgument?
}

///|
pub impl @json.FromJson for PickleStep with from_json(json, path) {
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
  let astNodeIds : Array[String] = match obj.get("astNodeIds") {
    Some(v) => @json.from_json(v, path=path.add_key("astNodeIds"))
    None =>
      raise @json.JsonDecodeError(
        (path, "PickleStep::from_json: missing astNodeIds"),
      )
  }
  let type_ : PickleStepType? = match obj.get("type") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("type")))
  }
  let argument : PickleStepArgument? = match obj.get("argument") {
    Some(Null) | None => None
    Some(v) => Some(@json.from_json(v, path=path.add_key("argument")))
  }
  PickleStep::{ id, text, astNodeIds, type_, argument }
}

///|
pub impl ToJson for PickleStep with to_json(self) {
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
pub struct PickleTag {
  name : String
  astNodeId : String
} derive(ToJson, FromJson)

///|
/// Pickle: compiled test case from a scenario.
pub struct Pickle {
  id : String
  uri : String
  name : String
  language : String
  steps : Array[PickleStep]
  tags : Array[PickleTag]
  astNodeIds : Array[String]
  location : Location?
} derive(ToJson, FromJson)

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
