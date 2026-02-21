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
}

///|
pub impl @json.FromJson for Envelope with from_json(json, path) {
  guard json is Object(obj) else {
    raise @json.JsonDecodeError((path, "Envelope::from_json: expected object"))
  }
  if obj.get("meta") is Some(v) {
    return Meta(@json.from_json(v, path=path.add_key("meta")))
  }
  if obj.get("source") is Some(v) {
    return Source(@json.from_json(v, path=path.add_key("source")))
  }
  if obj.get("parseError") is Some(v) {
    return ParseError(@json.from_json(v, path=path.add_key("parseError")))
  }
  if obj.get("testRunStarted") is Some(v) {
    return TestRunStarted(
      @json.from_json(v, path=path.add_key("testRunStarted")),
    )
  }
  if obj.get("testRunFinished") is Some(v) {
    return TestRunFinished(
      @json.from_json(v, path=path.add_key("testRunFinished")),
    )
  }
  if obj.get("undefinedParameterType") is Some(v) {
    return UndefinedParameterType(
      @json.from_json(v, path=path.add_key("undefinedParameterType")),
    )
  }
  if obj.get("testCaseStarted") is Some(v) {
    return TestCaseStarted(
      @json.from_json(v, path=path.add_key("testCaseStarted")),
    )
  }
  if obj.get("testCaseFinished") is Some(v) {
    return TestCaseFinished(
      @json.from_json(v, path=path.add_key("testCaseFinished")),
    )
  }
  if obj.get("testStepStarted") is Some(v) {
    return TestStepStarted(
      @json.from_json(v, path=path.add_key("testStepStarted")),
    )
  }
  if obj.get("testStepFinished") is Some(v) {
    return TestStepFinished(
      @json.from_json(v, path=path.add_key("testStepFinished")),
    )
  }
  if obj.get("attachment") is Some(v) {
    return Attachment(@json.from_json(v, path=path.add_key("attachment")))
  }
  if obj.get("externalAttachment") is Some(v) {
    return ExternalAttachment(
      @json.from_json(v, path=path.add_key("externalAttachment")),
    )
  }
  if obj.get("hook") is Some(v) {
    return Hook(@json.from_json(v, path=path.add_key("hook")))
  }
  if obj.get("stepDefinition") is Some(v) {
    return StepDefinition(
      @json.from_json(v, path=path.add_key("stepDefinition")),
    )
  }
  if obj.get("parameterType") is Some(v) {
    return ParameterType(@json.from_json(v, path=path.add_key("parameterType")))
  }
  if obj.get("suggestion") is Some(v) {
    return Suggestion(@json.from_json(v, path=path.add_key("suggestion")))
  }
  if obj.get("testRunHookStarted") is Some(v) {
    return TestRunHookStarted(
      @json.from_json(v, path=path.add_key("testRunHookStarted")),
    )
  }
  if obj.get("testRunHookFinished") is Some(v) {
    return TestRunHookFinished(
      @json.from_json(v, path=path.add_key("testRunHookFinished")),
    )
  }
  if obj.get("gherkinDocument") is Some(v) {
    return GherkinDocument(
      @json.from_json(v, path=path.add_key("gherkinDocument")),
    )
  }
  if obj.get("pickle") is Some(v) {
    return Pickle(@json.from_json(v, path=path.add_key("pickle")))
  }
  if obj.get("testCase") is Some(v) {
    return TestCase(@json.from_json(v, path=path.add_key("testCase")))
  }
  raise @json.JsonDecodeError(
    (path, "Envelope::from_json: no known message key found"),
  )
}

///|
pub impl ToJson for Envelope with to_json(self) {
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
      guard doc.feature is Some(f)
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
