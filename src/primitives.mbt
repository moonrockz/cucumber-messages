///|
/// Location: line and optional column in a text file (Cucumber Messages).
pub struct Location {
  line : Int
  column : Int?
} derive(ToJson, FromJson)

///|
/// Timestamp: seconds since Unix epoch + nanos (0..999_999_999).
/// `seconds` is an Int64 so that dates after 2038-01-19 fit.
pub struct Timestamp {
  seconds : Int64
  nanos : Int
}

///|
/// Duration: seconds + nanos (0..999_999_999).
pub struct Duration {
  seconds : Int64
  nanos : Int
}

///|
/// Decode an integral JSON number into Int64. The core `Int64` JSON
/// codec uses strings, but the protocol encodes `seconds` as a number.
fn seconds_from_json(
  json : Json,
  path : @json.JsonPath,
) -> Int64 raise @json.JsonDecodeError {
  guard json is Number(n, ..) && n == n.floor() else {
    raise @json.JsonDecodeError((path, "seconds: expected an integer number"))
  }
  // 2^63: the smallest Double above Int64 max; -2^63 is Int64 min.
  guard n >= -9223372036854775808.0 && n < 9223372036854775808.0 else {
    raise @json.JsonDecodeError((path, "seconds: out of Int64 range"))
  }
  n.to_int64()
}

///|
fn seconds_and_nanos_from_json(
  json : Json,
  path : @json.JsonPath,
  type_name : String,
) -> (Int64, Int) raise @json.JsonDecodeError {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError(
      (path, "\{type_name}::from_json: expected object"),
    )
  }
  guard obj.get("seconds") is Some(s) else {
    raise @json.JsonDecodeError(
      (path, "\{type_name}::from_json: missing seconds"),
    )
  }
  guard obj.get("nanos") is Some(n) else {
    raise @json.JsonDecodeError(
      (path, "\{type_name}::from_json: missing nanos"),
    )
  }
  let nanos_path = path.add_key("nanos")
  let nanos : Int = @json.from_json(n, path=nanos_path)
  check_int_range(nanos, nanos_path, min=0, max=999_999_999)
  (seconds_from_json(s, path.add_key("seconds")), nanos)
}

///|
pub impl @json.FromJson for Timestamp with fn from_json(json, path) {
  let (seconds, nanos) = seconds_and_nanos_from_json(json, path, "Timestamp")
  Timestamp::{ seconds, nanos, }
}

///|
pub impl ToJson for Timestamp with fn to_json(self) {
  { "seconds": Json::number(self.seconds.to_double()), "nanos": self.nanos }
}

///|
pub impl @json.FromJson for Duration with fn from_json(json, path) {
  let (seconds, nanos) = seconds_and_nanos_from_json(json, path, "Duration")
  Duration::{ seconds, nanos, }
}

///|
pub impl ToJson for Duration with fn to_json(self) {
  { "seconds": Json::number(self.seconds.to_double()), "nanos": self.nanos }
}

///|
/// Source media type for Source.mediaType.
pub enum SourceMediaType {
  GherkinPlain
  GherkinMarkdown
}

///|
pub impl @json.FromJson for SourceMediaType with fn from_json(json, path) {
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
pub impl ToJson for SourceMediaType with fn to_json(self) {
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
  let loc = Location::{ line: 5, column: Some(10), }
  let json = loc.to_json()
  let back : Location = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.line, loc.line)
  assert_eq(back.column, loc.column)
}

///|
test "timestamp roundtrip" {
  let ts = Timestamp::{ seconds: 1234567890, nanos: 123456789, }
  let json = ts.to_json()
  let back : Timestamp = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.seconds, ts.seconds)
  assert_eq(back.nanos, ts.nanos)
}

///|
test "duration roundtrip" {
  let d = Duration::{ seconds: 5, nanos: 500_000_000, }
  let json = d.to_json()
  let back : Duration = @json.from_json(json) catch { _ => panic() }
  assert_eq(back.seconds, d.seconds)
  assert_eq(back.nanos, d.nanos)
}

///|
test "timestamp after 2038 parses and serializes seconds as a number" {
  let json = @json.parse("{\"seconds\":4102444800,\"nanos\":5}")
  let ts : Timestamp = @json.from_json(json)
  assert_eq(ts.seconds, 4102444800L)
  assert_eq(ts.nanos, 5)
  assert_eq(ts.to_json().stringify(), "{\"seconds\":4102444800,\"nanos\":5}")
}

///|
test "duration with large seconds parses and serializes seconds as a number" {
  let json = @json.parse("{\"seconds\":3000000000,\"nanos\":0}")
  let d : Duration = @json.from_json(json)
  assert_eq(d.seconds, 3000000000L)
  assert_eq(d.to_json().stringify(), "{\"seconds\":3000000000,\"nanos\":0}")
}

///|
test "timestamp rejects fractional seconds" {
  let json = @json.parse("{\"seconds\":1.5,\"nanos\":0}")
  let ts : Timestamp? = Some(@json.from_json(json)) catch { _ => None }
  assert_true(ts is None)
}

///|
test "seconds outside the Int64 range are rejected" {
  for
    raw in [
      "{\"seconds\":1e300,\"nanos\":0}", "{\"seconds\":-1e300,\"nanos\":0}", "{\"seconds\":9223372036854775808,\"nanos\":0}",
    ] {
    let ts : Timestamp? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(ts is None, msg="accepted \{raw}")
    let d : Duration? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(d is None, msg="accepted \{raw}")
  }
}

///|
test "nanos outside 0..999999999 are rejected" {
  for nanos in ["-1", "1000000000"] {
    let raw = "{\"seconds\":1,\"nanos\":\{nanos}}"
    let ts : Timestamp? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(ts is None, msg="accepted nanos \{nanos}")
    let d : Duration? = Some(@json.from_json(@json.parse(raw))) catch {
      _ => None
    }
    assert_true(d is None, msg="accepted nanos \{nanos}")
  }
  for nanos in ["0", "999999999"] {
    let raw = "{\"seconds\":1,\"nanos\":\{nanos}}"
    let ts : Timestamp = @json.from_json(@json.parse(raw))
    assert_eq(ts.to_json(), @json.parse(raw))
  }
}
