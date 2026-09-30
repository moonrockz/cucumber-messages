///|
/// Envelope: exactly one message variant per JSON object.
pub enum Envelope {
  Meta(Meta)
  Source(Source)
  ParseError(ParseError)
  TestRunStarted(TestRunStarted)
  TestRunFinished(TestRunFinished)
  UndefinedParameterType(UndefinedParameterType)
  TestCaseStarted(TestCaseStarted)
  TestCaseFinished(TestCaseFinished)
  TestStepStarted(TestStepStarted)
  TestStepFinished(TestStepFinished)
  Attachment(Attachment)
  ExternalAttachment(ExternalAttachment)
  Hook(Hook)
  StepDefinition(StepDefinition)
  ParameterType(ParameterType)
  Suggestion(Suggestion)
  TestRunHookStarted(TestRunHookStarted)
  TestRunHookFinished(TestRunHookFinished)
  GherkinDocument(GherkinDocument)
  Pickle(Pickle)
  TestCase(TestCase)
  /// A message type this library does not know, for example one added by a
  /// newer protocol version. Holds the message key and its JSON value
  /// unchanged, so it serializes back to the same JSON.
  UnknownMessage(String, Json)
}

///|
pub impl @json.FromJson for Envelope with fn from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Envelope::from_json: expected object"))
  }
  let mut found : (String, Envelope)? = None
  for key, value in obj {
    let envelope = match decode_message(key, value, path.add_key(key)) {
      Some(envelope) => envelope
      None => UnknownMessage(key, value)
    }
    if found is Some((first, _)) {
      raise @json.JsonDecodeError(
        (
          path,
          "Envelope::from_json: more than one message key: \{first}, \{key}",
        ),
      )
    }
    found = Some((key, envelope))
  }
  guard found is Some((_, envelope)) else {
    raise @json.JsonDecodeError(
      (path, "Envelope::from_json: no message key found"),
    )
  }
  envelope
}

///|
let known_message_keys : Set[String] = Set::from_array([
  "meta", "source", "parseError", "testRunStarted", "testRunFinished", "undefinedParameterType",
  "testCaseStarted", "testCaseFinished", "testStepStarted", "testStepFinished", "attachment",
  "externalAttachment", "hook", "stepDefinition", "parameterType", "suggestion",
  "testRunHookStarted", "testRunHookFinished", "gherkinDocument", "pickle", "testCase",
])

///|
/// Decode the message stored under `key`, or `None` when `key` is not a
/// known message type. Only known messages are normalized.
fn decode_message(
  key : String,
  value : Json,
  path : @json.JsonPath,
) -> Envelope? raise @json.JsonDecodeError {
  guard known_message_keys.contains(key) else { return None }
  let value = normalize_envelope_json(value, path)
  let envelope = match key {
    "meta" => Meta(@json.from_json(value, path~))
    "source" => Source(@json.from_json(value, path~))
    "parseError" => ParseError(@json.from_json(value, path~))
    "testRunStarted" => TestRunStarted(@json.from_json(value, path~))
    "testRunFinished" => TestRunFinished(@json.from_json(value, path~))
    "undefinedParameterType" =>
      UndefinedParameterType(@json.from_json(value, path~))
    "testCaseStarted" => TestCaseStarted(@json.from_json(value, path~))
    "testCaseFinished" => TestCaseFinished(@json.from_json(value, path~))
    "testStepStarted" => TestStepStarted(@json.from_json(value, path~))
    "testStepFinished" => TestStepFinished(@json.from_json(value, path~))
    "attachment" => Attachment(@json.from_json(value, path~))
    "externalAttachment" => ExternalAttachment(@json.from_json(value, path~))
    "hook" => Hook(@json.from_json(value, path~))
    "stepDefinition" => StepDefinition(@json.from_json(value, path~))
    "parameterType" => ParameterType(@json.from_json(value, path~))
    "suggestion" => Suggestion(@json.from_json(value, path~))
    "testRunHookStarted" => TestRunHookStarted(@json.from_json(value, path~))
    "testRunHookFinished" => TestRunHookFinished(@json.from_json(value, path~))
    "gherkinDocument" => GherkinDocument(@json.from_json(value, path~))
    "pickle" => Pickle(@json.from_json(value, path~))
    "testCase" => TestCase(@json.from_json(value, path~))
    _ => return None
  }
  Some(envelope)
}

///|
pub impl ToJson for Envelope with fn to_json(self) {
  let o : Map[String, Json] = match self {
    Meta(m) => { "meta": m.to_json() }
    Source(s) => { "source": s.to_json() }
    ParseError(p) => { "parseError": p.to_json() }
    TestRunStarted(t) => { "testRunStarted": t.to_json() }
    TestRunFinished(t) => { "testRunFinished": t.to_json() }
    UndefinedParameterType(u) => { "undefinedParameterType": u.to_json() }
    TestCaseStarted(t) => { "testCaseStarted": t.to_json() }
    TestCaseFinished(t) => { "testCaseFinished": t.to_json() }
    TestStepStarted(t) => { "testStepStarted": t.to_json() }
    TestStepFinished(t) => { "testStepFinished": t.to_json() }
    Attachment(a) => { "attachment": a.to_json() }
    ExternalAttachment(e) => { "externalAttachment": e.to_json() }
    Hook(h) => { "hook": h.to_json() }
    StepDefinition(s) => { "stepDefinition": s.to_json() }
    ParameterType(p) => { "parameterType": p.to_json() }
    Suggestion(s) => { "suggestion": s.to_json() }
    TestRunHookStarted(t) => { "testRunHookStarted": t.to_json() }
    TestRunHookFinished(t) => { "testRunHookFinished": t.to_json() }
    GherkinDocument(g) => { "gherkinDocument": g.to_json() }
    Pickle(p) => { "pickle": p.to_json() }
    TestCase(t) => { "testCase": t.to_json() }
    UnknownMessage(key, value) => Map::from_array([(key, value)])
  }
  o.to_json()
}

///|
test "envelope meta decode and roundtrip" {
  let raw = "{\"meta\":{\"protocolVersion\":\"27.0.0\",\"implementation\":{\"name\":\"x\"},\"runtime\":{\"name\":\"y\"},\"os\":{\"name\":\"z\"},\"cpu\":{\"name\":\"w\"}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Meta(m) => {
      assert_eq(m.protocolVersion, "27.0.0")
      assert_eq(m.implementation.name, "x")
    }
    _ => panic()
  }
  let json2 = env.to_json()
  let back : Envelope = @json.from_json(json2) catch { _ => panic() }
  match (env, back) {
    (Meta(m), Meta(m2)) => assert_eq(m.protocolVersion, m2.protocolVersion)
    _ => panic()
  }
}

///|
test "envelope source roundtrip" {
  let raw = "{\"source\":{\"uri\":\"a.feature\",\"data\":\"Feature: y\",\"mediaType\":\"text/x.cucumber.gherkin+markdown\"}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Source(s) => assert_eq(s.uri, "a.feature")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    Source(s2) => assert_eq(s2.uri, "a.feature")
    _ => panic()
  }
}

///|
test "envelope attachment roundtrip" {
  let raw = "{\"attachment\":{\"body\":\"data\",\"contentEncoding\":\"BASE64\",\"mediaType\":\"image/png\"}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Attachment(a) => assert_eq(a.mediaType, "image/png")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    Attachment(a) => assert_eq(a.body, "data")
    _ => panic()
  }
}

///|
test "envelope external attachment roundtrip" {
  let raw = "{\"externalAttachment\":{\"url\":\"https://example.com/f.txt\",\"mediaType\":\"text/plain\"}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    ExternalAttachment(e) => assert_eq(e.url, "https://example.com/f.txt")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    ExternalAttachment(e) => assert_eq(e.mediaType, "text/plain")
    _ => panic()
  }
}

///|
test "envelope hook roundtrip" {
  let raw = "{\"hook\":{\"id\":\"h2\",\"sourceReference\":{}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Hook(h) => assert_eq(h.id, "h2")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    Hook(h) => assert_eq(h.id, "h2")
    _ => panic()
  }
}

///|
test "envelope step definition roundtrip" {
  let raw = "{\"stepDefinition\":{\"id\":\"sd2\",\"pattern\":{\"source\":\"^given$\",\"type\":\"REGULAR_EXPRESSION\"},\"sourceReference\":{}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    StepDefinition(sd) => assert_eq(sd.id, "sd2")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    StepDefinition(sd) => assert_eq(sd.id, "sd2")
    _ => panic()
  }
}

///|
test "envelope parameter type roundtrip" {
  let raw = "{\"parameterType\":{\"id\":\"pt2\",\"name\":\"int\",\"preferForRegularExpressionMatch\":false,\"regularExpressions\":[\"\\\\d+\"],\"useForSnippets\":true}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    ParameterType(pt) => assert_eq(pt.name, "int")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    ParameterType(pt) => assert_eq(pt.name, "int")
    _ => panic()
  }
}

///|
test "envelope suggestion roundtrip" {
  let raw = "{\"suggestion\":{\"id\":\"sug2\",\"pickleStepId\":\"ps2\",\"snippets\":[{\"language\":\"ruby\",\"code\":\"Given\"}]}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Suggestion(s) => assert_eq(s.id, "sug2")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    Suggestion(s) => assert_eq(s.snippets[0].language, "ruby")
    _ => panic()
  }
}

///|
test "envelope test run hook started roundtrip" {
  let raw = "{\"testRunHookStarted\":{\"id\":\"trhs2\",\"testRunStartedId\":\"trs2\",\"hookId\":\"h2\",\"timestamp\":{\"seconds\":200,\"nanos\":0}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    TestRunHookStarted(t) => assert_eq(t.id, "trhs2")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    TestRunHookStarted(t) => assert_eq(t.hookId, "h2")
    _ => panic()
  }
}

///|
test "envelope test run hook finished roundtrip" {
  let raw = "{\"testRunHookFinished\":{\"testRunHookStartedId\":\"trhs3\",\"result\":{\"duration\":{\"seconds\":0,\"nanos\":500},\"status\":\"FAILED\"},\"timestamp\":{\"seconds\":300,\"nanos\":0}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    TestRunHookFinished(t) => assert_eq(t.testRunHookStartedId, "trhs3")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    TestRunHookFinished(t) =>
      match t.result.status {
        Failed => ()
        _ => panic()
      }
    _ => panic()
  }
}

///|
test "envelope gherkin document roundtrip" {
  let raw = "{\"gherkinDocument\":{\"comments\":[],\"feature\":{\"location\":{\"line\":1},\"tags\":[],\"language\":\"en\",\"keyword\":\"Feature\",\"name\":\"X\",\"description\":\"\",\"children\":[]}}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    GherkinDocument(doc) => {
      guard! doc.feature is Some(f)
      assert_eq(f.name, "X")
    }
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    GherkinDocument(_) => ()
    _ => panic()
  }
}

///|
test "envelope pickle roundtrip" {
  let raw = "{\"pickle\":{\"id\":\"p2\",\"uri\":\"a.feature\",\"name\":\"Q\",\"language\":\"en\",\"steps\":[],\"tags\":[],\"astNodeIds\":[\"x\"]}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    Pickle(p) => assert_eq(p.name, "Q")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    Pickle(p) => assert_eq(p.id, "p2")
    _ => panic()
  }
}

///|
test "envelope test case roundtrip" {
  let raw = "{\"testCase\":{\"id\":\"tc3\",\"pickleId\":\"p3\",\"testSteps\":[{\"id\":\"ts3\"}]}}"
  let json = @json.parse(raw) catch { _ => panic() }
  let env : Envelope = @json.from_json(json) catch { _ => panic() }
  match env {
    TestCase(tc) => assert_eq(tc.id, "tc3")
    _ => panic()
  }
  let back : Envelope = @json.from_json(env.to_json()) catch { _ => panic() }
  match back {
    TestCase(tc) => assert_eq(tc.pickleId, "p3")
    _ => panic()
  }
}

///|
test "envelope treats null optional fields as absent" {
  let raw =
    #|{"meta":{"protocolVersion":"34.2.1","implementation":{"name":"x","version":null},"runtime":{"name":"x"},"os":{"name":"x"},"cpu":{"name":"x"},"ci":null}}
  guard! parse_ndjson_line(raw) is Meta(m)
  assert_eq(m.ci is None, true)
  assert_eq(m.implementation.version, None)
  assert_eq(
    m.to_json().stringify(),
    "{\"protocolVersion\":\"34.2.1\",\"implementation\":{\"name\":\"x\"},\"runtime\":{\"name\":\"x\"},\"os\":{\"name\":\"x\"},\"cpu\":{\"name\":\"x\"}}",
  )
}

///|
test "envelope treats null in a nested array element as absent" {
  let raw =
    #|{"testCase":{"id":"tc","pickleId":"p","testSteps":[{"id":"s","hookId":null,"pickleStepId":"ps","stepDefinitionIds":["sd"],"stepMatchArgumentsLists":null}],"testRunStartedId":null}}
  guard! parse_ndjson_line(raw) is TestCase(tc)
  assert_eq(tc.testSteps[0].hookId, None)
  assert_eq(tc.testRunStartedId, None)
}

///|
test "envelope reports null on a required field as missing" {
  let raw =
    #|{"testRunStarted":{"timestamp":null}}
  let message = try parse_ndjson_line(raw) catch {
    e => e.to_string()
  } noraise {
    _ => "no error"
  }
  assert_true(message.contains("Missing field timestamp"))
}

///|
test "envelope rejects fractional numbers" {
  for
    raw in [
      "{\"parseError\":{\"source\":{\"uri\":\"a\",\"location\":{\"line\":1.5}},\"message\":\"m\"}}",
      "{\"testCaseStarted\":{\"attempt\":0.5,\"id\":\"i\",\"testCaseId\":\"t\",\"timestamp\":{\"seconds\":1,\"nanos\":0}}}",
    ] {
    let message = try parse_ndjson_line(raw) catch {
      e => e.to_string()
    } noraise {
      _ => "no error"
    }
    assert_true(
      message.contains("expected an integer"),
      msg="\{raw}: \{message}",
    )
  }
}

///|
test "envelope with two message keys is rejected" {
  let raw =
    #|{"testRunStarted":{"timestamp":{"seconds":1,"nanos":0}},"testRunFinished":{"success":true,"timestamp":{"seconds":1,"nanos":0}}}
  let message = try parse_ndjson_line(raw) catch {
    e => e.to_string()
  } noraise {
    _ => "no error"
  }
  assert_true(message.contains("more than one message"), msg=message)
}

///|
test "envelope keeps an unknown message type" {
  let raw =
    #|{"futureMessage":{"id":"f1","ratio":0.5,"note":null,"items":[1,2]}}
  let envelope = parse_ndjson_line(raw)
  guard! envelope is UnknownMessage(key, value)
  assert_eq(key, "futureMessage")
  guard! @json.parse(raw) is Object(obj)
  assert_eq(Some(value), obj.get("futureMessage"))
  assert_eq(envelope.to_json(), @json.parse(raw))
}

///|
test "envelope with a known and an unknown message key is rejected" {
  let raw =
    #|{"testRunStarted":{"timestamp":{"seconds":1,"nanos":0}},"futureMessage":{}}
  let message = try parse_ndjson_line(raw) catch {
    e => e.to_string()
  } noraise {
    _ => "no error"
  }
  assert_true(message.contains("more than one message"), msg=message)
}

///|
test "empty envelope is rejected" {
  let message = try parse_ndjson_line("{}") catch {
    e => e.to_string()
  } noraise {
    _ => "no error"
  }
  assert_true(message.contains("no message"), msg=message)
}
