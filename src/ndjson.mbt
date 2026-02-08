///|
/// Parse a single NDJSON line into an Envelope.
pub fn parse_ndjson_line(line : String) -> Envelope raise {
  let json = @json.parse(line)
  @json.from_json(json)
}

///|
/// Serialize an Envelope to a single NDJSON line (no trailing newline).
pub fn Envelope::to_ndjson_line(self : Envelope) -> String {
  self.to_json().stringify()
}

///|
/// Parse an NDJSON string (multiple lines) into an array of Envelopes.
/// Blank lines are skipped.
pub fn parse_ndjson(input : String) -> Array[Envelope] raise {
  let envelopes : Array[Envelope] = []
  let lines = input.split("\n")
  for line in lines {
    let trimmed = line.trim().to_string()
    if trimmed.length() > 0 {
      envelopes.push(parse_ndjson_line(trimmed))
    }
  }
  envelopes
}

///|
/// Serialize an array of Envelopes to NDJSON (one JSON object per line).
pub fn envelopes_to_ndjson(envelopes : Array[Envelope]) -> String {
  let buf = StringBuilder::new()
  for i, env in envelopes {
    if i > 0 {
      buf.write_char('\n')
    }
    buf.write_string(env.to_ndjson_line())
  }
  buf.to_string()
}

///|
test "ndjson single line roundtrip" {
  let env = Envelope::Meta(Meta::{
    protocolVersion: "27.0.0",
    implementation: Product::{ name: "test", version: None },
    runtime: Product::{ name: "moonbit", version: None },
    os: Product::{ name: "linux", version: None },
    cpu: Product::{ name: "amd64", version: None },
    ci: None,
  })
  let line = env.to_ndjson_line()
  let back = parse_ndjson_line(line) catch { _ => panic() }
  match back {
    Meta(m) => assert_eq(m.protocolVersion, "27.0.0")
    _ => panic()
  }
}

///|
test "ndjson multi-line parse" {
  let line1 = "{\"meta\":{\"protocolVersion\":\"27.0.0\",\"implementation\":{\"name\":\"x\"},\"runtime\":{\"name\":\"y\"},\"os\":{\"name\":\"z\"},\"cpu\":{\"name\":\"w\"}}}"
  let line2 = "{\"source\":{\"uri\":\"a.feature\",\"data\":\"Feature: A\",\"mediaType\":\"text/x.cucumber.gherkin+plain\"}}"
  let input = line1 + "\n" + line2 + "\n"
  let envelopes = parse_ndjson(input) catch { _ => panic() }
  assert_eq(envelopes.length(), 2)
  match envelopes[0] {
    Meta(m) => assert_eq(m.protocolVersion, "27.0.0")
    _ => panic()
  }
  match envelopes[1] {
    Source(s) => assert_eq(s.uri, "a.feature")
    _ => panic()
  }
}

///|
test "ndjson roundtrip multi envelope" {
  let envs = [
    Envelope::TestRunStarted(TestRunStarted::{
      timestamp: Timestamp::{ seconds: 1, nanos: 0 },
      id: None,
    }),
    Envelope::TestRunFinished(TestRunFinished::{
      message: None,
      success: true,
      timestamp: Timestamp::{ seconds: 2, nanos: 0 },
      exception: None,
      testRunStartedId: None,
    }),
  ]
  let ndjson = envelopes_to_ndjson(envs)
  let back = parse_ndjson(ndjson) catch { _ => panic() }
  assert_eq(back.length(), 2)
  match back[0] {
    TestRunStarted(t) => assert_eq(t.timestamp.seconds, 1)
    _ => panic()
  }
  match back[1] {
    TestRunFinished(t) => assert_eq(t.success, true)
    _ => panic()
  }
}

///|
test "ndjson skips blank lines" {
  let input = "\n{\"meta\":{\"protocolVersion\":\"27.0.0\",\"implementation\":{\"name\":\"x\"},\"runtime\":{\"name\":\"y\"},\"os\":{\"name\":\"z\"},\"cpu\":{\"name\":\"w\"}}}\n\n"
  let envelopes = parse_ndjson(input) catch { _ => panic() }
  assert_eq(envelopes.length(), 1)
}

///|
test "fixture all_variants ndjson roundtrip" {
  // 23 lines in the fixture: all 21 Envelope variant types represented
  // (some variants like testStepStarted/testStepFinished appear twice for realism)
  let fixture =
    #|{"meta":{"protocolVersion":"27.0.0","implementation":{"name":"cucumber-moonbit"},"runtime":{"name":"moonbit"},"os":{"name":"linux"},"cpu":{"name":"amd64"}}}
    #|{"source":{"uri":"features/hello.feature","data":"Feature: Hello\n  Scenario: World\n    Given a step","mediaType":"text/x.cucumber.gherkin+plain"}}
    #|{"gherkinDocument":{"uri":"features/hello.feature","comments":[],"feature":{"location":{"line":1},"tags":[],"language":"en","keyword":"Feature","name":"Hello","description":"","children":[{"scenario":{"location":{"line":2},"tags":[],"keyword":"Scenario","name":"World","description":"","steps":[{"location":{"line":3},"keyword":"Given ","text":"a step","id":"step-1","keywordType":"Context"}],"examples":[],"id":"scenario-1"}}]}}}
    #|{"pickle":{"id":"pickle-1","uri":"features/hello.feature","name":"World","language":"en","steps":[{"id":"pickle-step-1","text":"a step","astNodeIds":["step-1"],"pickleStepType":"Context"}],"tags":[],"astNodeIds":["scenario-1"]}}
    #|{"stepDefinition":{"id":"step-def-1","pattern":{"source":"a step","patternType":"CUCUMBER_EXPRESSION"},"sourceReference":{"uri":"steps/steps.mbt","location":{"line":5}}}}
    #|{"hook":{"id":"hook-1","sourceReference":{"uri":"support/hooks.mbt","location":{"line":10}},"name":"before all","hookType":"BEFORE_TEST_RUN"}}
    #|{"parameterType":{"id":"param-type-1","name":"color","preferForRegularExpressionMatch":true,"regularExpressions":["red|blue|green"],"useForSnippets":true,"sourceReference":{"uri":"support/params.mbt","location":{"line":1}}}}
    #|{"testCase":{"id":"test-case-1","pickleId":"pickle-1","testSteps":[{"id":"test-step-1","hookId":"hook-1"},{"id":"test-step-2","pickleStepId":"pickle-step-1","stepDefinitionIds":["step-def-1"],"stepMatchArgumentsLists":[{"stepMatchArguments":[]}]}]}}
    #|{"testRunStarted":{"timestamp":{"seconds":1700000000,"nanos":0}}}
    #|{"testRunHookStarted":{"id":"run-hook-started-1","testRunStartedId":"test-run-1","hookId":"hook-1","timestamp":{"seconds":1700000001,"nanos":0}}}
    #|{"testRunHookFinished":{"testRunHookStartedId":"run-hook-started-1","result":{"duration":{"seconds":0,"nanos":50000000},"status":"PASSED"},"timestamp":{"seconds":1700000001,"nanos":50000000}}}
    #|{"testCaseStarted":{"attempt":0,"id":"test-case-started-1","testCaseId":"test-case-1","timestamp":{"seconds":1700000002,"nanos":0}}}
    #|{"testStepStarted":{"testCaseStartedId":"test-case-started-1","testStepId":"test-step-1","timestamp":{"seconds":1700000002,"nanos":100000}}}
    #|{"testStepFinished":{"testCaseStartedId":"test-case-started-1","testStepId":"test-step-1","testStepResult":{"duration":{"seconds":0,"nanos":1000000},"status":"PASSED"},"timestamp":{"seconds":1700000002,"nanos":1100000}}}
    #|{"testStepStarted":{"testCaseStartedId":"test-case-started-1","testStepId":"test-step-2","timestamp":{"seconds":1700000002,"nanos":2000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"test-case-started-1","testStepId":"test-step-2","testStepResult":{"duration":{"seconds":0,"nanos":5000000},"status":"PASSED"},"timestamp":{"seconds":1700000002,"nanos":7000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"test-case-started-1","timestamp":{"seconds":1700000003,"nanos":0},"willBeRetried":false}}
    #|{"testRunFinished":{"success":true,"timestamp":{"seconds":1700000004,"nanos":0}}}
    #|{"attachment":{"body":"Screenshot data","contentEncoding":"BASE64","mediaType":"image/png","testCaseStartedId":"test-case-started-1","testStepId":"test-step-2"}}
    #|{"externalAttachment":{"url":"https://example.com/report.html","mediaType":"text/html"}}
    #|{"parseError":{"source":{"uri":"bad.feature","location":{"line":5,"column":1}},"message":"expected: Feature, got: Scenario"}}
    #|{"undefinedParameterType":{"expression":"a {color} thing","name":"color"}}
    #|{"suggestion":{"id":"sug-1","pickleStepId":"pickle-step-1","snippets":[{"language":"moonbit","code":"fn step_a_step(world: World) -> Unit { ... }"}]}}
  let envelopes = parse_ndjson(fixture)
  assert_eq(envelopes.length(), 23)
  // Verify first message is Meta
  match envelopes[0] {
    Meta(m) => assert_eq(m.protocolVersion, "27.0.0")
    _ => panic()
  }
  // Verify last message is Suggestion
  match envelopes[22] {
    Suggestion(s) => assert_eq(s.id, "sug-1")
    _ => panic()
  }
  // Round-trip: serialize to NDJSON and parse back
  let ndjson = envelopes_to_ndjson(envelopes)
  let back = parse_ndjson(ndjson)
  assert_eq(back.length(), 23)
  // Spot-check several variants in the round-tripped result
  match back[1] {
    Source(s) => assert_eq(s.uri, "features/hello.feature")
    _ => panic()
  }
  match back[2] {
    GherkinDocument(doc) => {
      guard doc.feature is Some(f)
      assert_eq(f.name, "Hello")
    }
    _ => panic()
  }
  match back[3] {
    Pickle(p) => assert_eq(p.name, "World")
    _ => panic()
  }
  match back[4] {
    StepDefinition(sd) => assert_eq(sd.pattern.source, "a step")
    _ => panic()
  }
  match back[5] {
    Hook(h) => assert_eq(h.name, Some("before all"))
    _ => panic()
  }
  match back[6] {
    ParameterType(pt) => assert_eq(pt.name, "color")
    _ => panic()
  }
  match back[7] {
    TestCase(tc) => assert_eq(tc.testSteps.length(), 2)
    _ => panic()
  }
  match back[8] {
    TestRunStarted(t) => assert_eq(t.timestamp.seconds, 1700000000)
    _ => panic()
  }
  match back[18] {
    Attachment(a) => assert_eq(a.mediaType, "image/png")
    _ => panic()
  }
  match back[19] {
    ExternalAttachment(e) => assert_eq(e.mediaType, "text/html")
    _ => panic()
  }
  match back[20] {
    ParseError(p) => assert_eq(p.message, "expected: Feature, got: Scenario")
    _ => panic()
  }
  match back[21] {
    UndefinedParameterType(u) => assert_eq(u.name, "color")
    _ => panic()
  }
}
