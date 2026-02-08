///|
/// Comment: a comment in a Gherkin document.
pub struct Comment {
  location : Location
  text : String
} derive(ToJson, FromJson)

///|
/// Tag: a tag in a Gherkin document.
pub struct Tag {
  location : Location
  name : String
  id : String
} derive(ToJson, FromJson)

///|
/// TableCell: a cell in a data table row.
pub struct TableCell {
  location : Location
  value : String
} derive(ToJson, FromJson)

///|
/// TableRow: a row in a data table.
pub struct TableRow {
  location : Location
  cells : Array[TableCell]
  id : String
} derive(ToJson, FromJson)

///|
/// DataTable: a data table in a step.
pub struct DataTable {
  location : Location
  rows : Array[TableRow]
} derive(ToJson, FromJson)

///|
/// DocString: a doc string in a step.
pub struct DocString {
  location : Location
  content : String
  delimiter : String
  mediaType : String?
} derive(ToJson, FromJson)

///|
/// KeywordType: keyword type for a step.
pub enum KeywordType {
  Unknown
  Context
  Action
  Outcome
  Conjunction
}

///|
pub impl @json.FromJson for KeywordType with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "KeywordType::from_json: expected string"),
    )
  }
  match s {
    "Unknown" => Unknown
    "Context" => Context
    "Action" => Action
    "Outcome" => Outcome
    "Conjunction" => Conjunction
    _ =>
      raise @json.JsonDecodeError(
        (path, "KeywordType::from_json: expected a valid keyword type"),
      )
  }
}

///|
pub impl ToJson for KeywordType with to_json(self) {
  match self {
    Unknown => "Unknown".to_json()
    Context => "Context".to_json()
    Action => "Action".to_json()
    Outcome => "Outcome".to_json()
    Conjunction => "Conjunction".to_json()
  }
}

///|
/// Step: a step in a scenario or background.
pub struct Step {
  location : Location
  keyword : String
  text : String
  id : String
  keywordType : KeywordType?
  docString : DocString?
  dataTable : DataTable?
} derive(ToJson, FromJson)

///|
/// Background: a background in a feature or rule.
pub struct Background {
  location : Location
  keyword : String
  name : String
  description : String
  steps : Array[Step]
  id : String
} derive(ToJson, FromJson)

///|
/// Examples: examples table for a scenario outline.
pub struct Examples {
  location : Location
  tags : Array[Tag]
  keyword : String
  name : String
  description : String
  tableHeader : TableRow?
  tableBody : Array[TableRow]
  id : String
} derive(ToJson, FromJson)

///|
/// Scenario: a scenario in a feature or rule.
pub struct Scenario {
  location : Location
  tags : Array[Tag]
  keyword : String
  name : String
  description : String
  steps : Array[Step]
  examples : Array[Examples]
  id : String
} derive(ToJson, FromJson)

///|
/// RuleChild: a child of a Rule (background or scenario).
pub struct RuleChild {
  background : Background?
  scenario : Scenario?
} derive(ToJson, FromJson)

///|
/// Rule: a rule grouping scenarios in a feature.
pub struct Rule {
  location : Location
  tags : Array[Tag]
  keyword : String
  name : String
  description : String
  children : Array[RuleChild]
  id : String
} derive(ToJson, FromJson)

///|
/// FeatureChild: a child of a Feature (rule, background, or scenario).
pub struct FeatureChild {
  rule : Rule?
  background : Background?
  scenario : Scenario?
} derive(ToJson, FromJson)

///|
/// Feature: a feature in a Gherkin document.
pub struct Feature {
  location : Location
  tags : Array[Tag]
  language : String
  keyword : String
  name : String
  description : String
  children : Array[FeatureChild]
} derive(ToJson, FromJson)

///|
/// GherkinDocument: parsed Gherkin AST.
pub struct GherkinDocument {
  uri : String?
  feature : Feature?
  comments : Array[Comment]
} derive(ToJson, FromJson)

///|
test "keyword type roundtrip" {
  let json = @json.parse("\"Context\"") catch { _ => panic() }
  let kt : KeywordType = @json.from_json(json) catch { _ => panic() }
  match kt {
    Context => ()
    _ => panic()
  }
  assert_eq(kt.to_json().stringify(), "\"Context\"")
}

///|
test "gherkin document minimal roundtrip" {
  let raw = "{\"comments\":[]}"
  let json = @json.parse(raw) catch { _ => panic() }
  let doc : GherkinDocument = @json.from_json(json) catch { _ => panic() }
  assert_eq(doc.comments.length(), 0)
  assert_eq(doc.uri, None)
  assert_true(doc.feature is None)
  let back : GherkinDocument = @json.from_json(doc.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.comments.length(), 0)
}

///|
test "gherkin document with feature roundtrip" {
  let raw = "{\"uri\":\"test.feature\",\"comments\":[{\"location\":{\"line\":1},\"text\":\"# a comment\"}],\"feature\":{\"location\":{\"line\":2},\"tags\":[],\"language\":\"en\",\"keyword\":\"Feature\",\"name\":\"Test\",\"description\":\"\",\"children\":[]}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let doc : GherkinDocument = @json.from_json(json) catch { _ => panic() }
  assert_eq(doc.uri, Some("test.feature"))
  assert_eq(doc.comments.length(), 1)
  assert_eq(doc.comments[0].text, "# a comment")
  guard doc.feature is Some(f)
  assert_eq(f.name, "Test")
  assert_eq(f.language, "en")
  let back : GherkinDocument = @json.from_json(doc.to_json()) catch {
    _ => panic()
  }
  guard back.feature is Some(f2)
  assert_eq(f2.name, "Test")
}

///|
test "gherkin document with scenario roundtrip" {
  let raw = "{\"comments\":[],\"feature\":{\"location\":{\"line\":1},\"tags\":[],\"language\":\"en\",\"keyword\":\"Feature\",\"name\":\"F\",\"description\":\"\",\"children\":[{\"scenario\":{\"location\":{\"line\":3},\"tags\":[{\"location\":{\"line\":2},\"name\":\"@smoke\",\"id\":\"t1\"}],\"keyword\":\"Scenario\",\"name\":\"S\",\"description\":\"\",\"steps\":[{\"location\":{\"line\":4},\"keyword\":\"Given \",\"text\":\"a step\",\"id\":\"s1\",\"keywordType\":\"Context\"}],\"examples\":[],\"id\":\"sc1\"}}]}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let doc : GherkinDocument = @json.from_json(json) catch { _ => panic() }
  guard doc.feature is Some(f)
  assert_eq(f.children.length(), 1)
  guard f.children[0].scenario is Some(sc)
  assert_eq(sc.name, "S")
  assert_eq(sc.tags.length(), 1)
  assert_eq(sc.tags[0].name, "@smoke")
  assert_eq(sc.steps.length(), 1)
  assert_eq(sc.steps[0].text, "a step")
  guard sc.steps[0].keywordType is Some(kt)
  match kt {
    Context => ()
    _ => panic()
  }
  let back : GherkinDocument = @json.from_json(doc.to_json()) catch {
    _ => panic()
  }
  guard back.feature is Some(f2)
  guard f2.children[0].scenario is Some(sc2)
  assert_eq(sc2.name, "S")
}
