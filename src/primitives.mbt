///|
/// Location: line and optional column in a text file (Cucumber Messages).
pub struct Location {
  line : Int
  column : Int?
} derive(ToJson, FromJson)

///|
/// Timestamp: seconds since Unix epoch + nanos (0..999_999_999).
pub struct Timestamp {
  seconds : Int
  nanos : Int
} derive(ToJson, FromJson)

///|
/// Duration: seconds + nanos (0..999_999_999).
pub struct Duration {
  seconds : Int
  nanos : Int
} derive(ToJson, FromJson)

///|
/// Source media type for Source.mediaType.
pub enum SourceMediaType {
  GherkinPlain
  GherkinMarkdown
}

///|
pub impl @json.FromJson for SourceMediaType with from_json(json, path) {
  guard json is String(s) else {
    raise @json.JsonDecodeError(
      (path, "SourceMediaType::from_json: expected string"),
    )
  }
  match s {
    "text/x.cucumber.gherkin+plain" => GherkinPlain
    "text/x.cucumber.gherkin+markdown" => GherkinMarkdown
    _ =>
      raise @json.JsonDecodeError(
        (
          path, "SourceMediaType::from_json: expected text/x.cucumber.gherkin+plain or text/x.cucumber.gherkin+markdown",
        ),
      )
  }
}

///|
pub impl ToJson for SourceMediaType with to_json(self) {
  match self {
    GherkinPlain => "text/x.cucumber.gherkin+plain".to_json()
    GherkinMarkdown => "text/x.cucumber.gherkin+markdown".to_json()
  }
}

///|
test "location decode line only" {
  let json = @json.parse("{\"line\": 1}") catch { _ => panic() }
  let loc : Location = @json.from_json(json) catch { _ => panic() }
  assert_eq(loc.line, 1)
  assert_eq(loc.column, None)
}

///|
test "location decode line and column" {
  let json = @json.parse("{\"line\": 2, \"column\": 3}") catch { _ => panic() }
  let loc : Location = @json.from_json(json) catch { _ => panic() }
  assert_eq(loc.line, 2)
  assert_eq(loc.column, Some(3))
}

///|
test "location roundtrip" {
  let loc = Location::{ line: 5, column: Some(10) }
  let json = loc.to_json()
  let back : Location = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.line, loc.line)
  assert_eq(back.column, loc.column)
}

///|
test "timestamp roundtrip" {
  let ts = Timestamp::{ seconds: 1234567890, nanos: 123456789 }
  let json = ts.to_json()
  let back : Timestamp = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.seconds, ts.seconds)
  assert_eq(back.nanos, ts.nanos)
}

///|
test "duration roundtrip" {
  let d = Duration::{ seconds: 5, nanos: 500_000_000 }
  let json = d.to_json()
  let back : Duration = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.seconds, d.seconds)
  assert_eq(back.nanos, d.nanos)
}
