///|
/// StepDefinitionPatternType: pattern type for step definitions.
pub enum StepDefinitionPatternType {
  CucumberExpression
  RegularExpression
}

///|
pub impl @json.FromJson for StepDefinitionPatternType with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "StepDefinitionPatternType::from_json: expected string"),
    )
  }
  match s {
    "CUCUMBER_EXPRESSION" => CucumberExpression
    "REGULAR_EXPRESSION" => RegularExpression
    _ =>
      raise @json.JsonDecodeError(
        (
          path, "StepDefinitionPatternType::from_json: expected CUCUMBER_EXPRESSION or REGULAR_EXPRESSION",
        ),
      )
  }
}

///|
pub impl ToJson for StepDefinitionPatternType with to_json(self) {
  match self {
    CucumberExpression => "CUCUMBER_EXPRESSION".to_json()
    RegularExpression => "REGULAR_EXPRESSION".to_json()
  }
}

///|
/// StepDefinitionPattern: pattern for a step definition.
/// Note: JSON key is "type" (not "patternType") to match upstream schema.
pub struct StepDefinitionPattern {
  source : String
  type_ : StepDefinitionPatternType
}

///|
pub impl @json.FromJson for StepDefinitionPattern with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "StepDefinitionPattern::from_json: expected object"),
    )
  }
  let source = match obj.get("source") {
    Some(v) => @json.from_json(v, path=path.add_key("source"))
    None =>
      raise @json.JsonDecodeError(
        (path, "StepDefinitionPattern::from_json: missing source"),
      )
  }
  let type_ = match obj.get("type") {
    Some(v) => @json.from_json(v, path=path.add_key("type"))
    None =>
      raise @json.JsonDecodeError(
        (path, "StepDefinitionPattern::from_json: missing type"),
      )
  }
  StepDefinitionPattern::{ source, type_ }
}

///|
pub impl ToJson for StepDefinitionPattern with to_json(self) {
  let o : Map[String, Json] = {
    "source": self.source.to_json(),
    "type": self.type_.to_json(),
  }
  o.to_json()
}

///|
/// StepDefinition: step definition with pattern and source reference.
pub struct StepDefinition {
  id : String
  pattern : StepDefinitionPattern
  sourceReference : SourceReference
} derive(ToJson, FromJson)

///|
/// ParameterType: custom parameter type for step expressions.
pub struct ParameterType {
  id : String
  name : String
  preferForRegularExpressionMatch : Bool
  regularExpressions : Array[String]
  useForSnippets : Bool
  sourceReference : SourceReference?
} derive(ToJson, FromJson)

///|
/// Snippet: code snippet for a suggestion.
pub struct Snippet {
  language : String
  code : String
} derive(ToJson, FromJson)

///|
/// Suggestion: snippet suggestion for an undefined step.
pub struct Suggestion {
  id : String
  pickleStepId : String
  snippets : Array[Snippet]
} derive(ToJson, FromJson)

///|
test "step definition pattern type roundtrip" {
  let json = @json.parse("\"CUCUMBER_EXPRESSION\"") catch { _ => panic() }
  let pt : StepDefinitionPatternType = @json.from_json(json) catch {
    _ => panic()
  }
  match pt {
    CucumberExpression => ()
    _ => panic()
  }
  assert_eq(pt.to_json().stringify(), "\"CUCUMBER_EXPRESSION\"")
}

///|
test "step definition roundtrip" {
  let raw = "{\"id\":\"sd1\",\"pattern\":{\"source\":\"I have {int} cukes\",\"type\":\"CUCUMBER_EXPRESSION\"},\"sourceReference\":{}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let sd : StepDefinition = @json.from_json(json) catch { _ => panic() }
  assert_eq(sd.id, "sd1")
  assert_eq(sd.pattern.source, "I have {int} cukes")
  let back : StepDefinition = @json.from_json(sd.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.pattern.source, sd.pattern.source)
}

///|
test "parameter type roundtrip" {
  let raw = "{\"id\":\"pt1\",\"name\":\"color\",\"preferForRegularExpressionMatch\":true,\"regularExpressions\":[\"red|blue\"],\"useForSnippets\":false}"
  let json = @json.parse(raw) catch { _ => panic() }
  let pt : ParameterType = @json.from_json(json) catch { _ => panic() }
  assert_eq(pt.id, "pt1")
  assert_eq(pt.name, "color")
  assert_eq(pt.preferForRegularExpressionMatch, true)
  assert_eq(pt.useForSnippets, false)
  let back : ParameterType = @json.from_json(pt.to_json()) catch {
    _ => panic()
  }
  assert_eq(back.name, pt.name)
}

///|
test "suggestion roundtrip" {
  let raw = "{\"id\":\"sug1\",\"pickleStepId\":\"ps1\",\"snippets\":[{\"language\":\"java\",\"code\":\"@Given\"}]}"
  let json = @json.parse(raw) catch { _ => panic() }
  let sug : Suggestion = @json.from_json(json) catch { _ => panic() }
  assert_eq(sug.id, "sug1")
  assert_eq(sug.snippets[0].language, "java")
  let back : Suggestion = @json.from_json(sug.to_json()) catch { _ => panic() }
  assert_eq(back.snippets[0].code, "@Given")
}
