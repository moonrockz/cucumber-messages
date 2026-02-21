///|
/// CCK compatibility test: parse the "minimal" sample from the Cucumber
/// Compatibility Kit to validate our deserialization against v31.1.0 reference data.
test "cck/minimal: parse all envelopes" {
  let data =
    #|{"meta":{"protocolVersion":"31.1.0","implementation":{"name":"fake-cucumber","version":"123.45.6"},"cpu":{"name":"arm64"},"os":{"name":"darwin","version":"24.5.0"},"runtime":{"name":"Node.js","version":"24.4.1"},"ci":{"name":"GitHub Actions","url":"https://github.com/cucumber-ltd/shouty.rb/actions/runs/154666429","buildNumber":"154666429","git":{"revision":"99684bcacf01d95875834d87903dcb072306c9ad","remote":"https://github.com/cucumber-ltd/shouty.rb.git","branch":"main"}}}}
    #|{"source":{"data":"Feature: minimal\n  \n  Cucumber doesn't execute this markdown, but @cucumber/react renders it.\n  \n  * This is\n  * a bullet\n  * list\n  \n  Scenario: cukes\n    Given I have 42 cukes in my belly\n","uri":"samples/minimal/minimal.feature","mediaType":"text/x.cucumber.gherkin+plain"}}
    #|{"gherkinDocument":{"feature":{"tags":[],"location":{"line":1,"column":1},"language":"en","keyword":"Feature","name":"minimal","description":"  Cucumber doesn't execute this markdown, but @cucumber/react renders it.\n  \n  * This is\n  * a bullet\n  * list","children":[{"scenario":{"id":"1","tags":[],"location":{"line":9,"column":3},"keyword":"Scenario","name":"cukes","description":"","steps":[{"id":"0","location":{"line":10,"column":5},"keyword":"Given ","keywordType":"Context","text":"I have 42 cukes in my belly"}],"examples":[]}}]},"comments":[],"uri":"samples/minimal/minimal.feature"}}
    #|{"pickle":{"id":"3","uri":"samples/minimal/minimal.feature","location":{"line":9,"column":3},"astNodeIds":["1"],"tags":[],"name":"cukes","language":"en","steps":[{"id":"2","text":"I have 42 cukes in my belly","type":"Context","astNodeIds":["0"]}]}}
    #|{"stepDefinition":{"id":"4","pattern":{"type":"CUCUMBER_EXPRESSION","source":"I have {int} cukes in my belly"},"sourceReference":{"uri":"samples/minimal/minimal.ts","location":{"line":3}}}}
    #|{"testRunStarted":{"id":"5","timestamp":{"seconds":0,"nanos":0}}}
    #|{"testCase":{"id":"6","pickleId":"3","testSteps":[{"id":"7","pickleStepId":"2","stepDefinitionIds":["4"],"stepMatchArgumentsLists":[{"stepMatchArguments":[{"group":{"start":7,"value":"42"},"parameterTypeName":"int"}]}]}],"testRunStartedId":"5"}}
    #|{"testCaseStarted":{"id":"8","testCaseId":"6","timestamp":{"seconds":0,"nanos":1000000},"attempt":0}}
    #|{"testStepStarted":{"testCaseStartedId":"8","testStepId":"7","timestamp":{"seconds":0,"nanos":2000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"8","testStepId":"7","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":3000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"8","timestamp":{"seconds":0,"nanos":4000000},"willBeRetried":false}}
    #|{"testRunFinished":{"testRunStartedId":"5","timestamp":{"seconds":0,"nanos":5000000},"success":true}}
  let envelopes = parse_ndjson(data)
  assert_eq(envelopes.length(), 12)
  // Verify Meta
  match envelopes[0] {
    Meta(m) => assert_eq(m.protocolVersion, "31.1.0")
    _ => panic()
  }
  // Verify Pickle step type
  match envelopes[3] {
    Pickle(p) => {
      guard p.steps[0].type_ is Some(PickleStepType::Context)
    }
    _ => panic()
  }
  // Verify StepDefinition pattern type
  match envelopes[4] {
    StepDefinition(sd) => {
      guard sd.pattern.type_ is CucumberExpression
    }
    _ => panic()
  }
  // Verify TestRunFinished
  match envelopes[11] {
    TestRunFinished(t) => assert_eq(t.success, true)
    _ => panic()
  }
}

///|
/// CCK compatibility test: parse the "hooks" sample.
test "cck/hooks: parse all envelopes" {
  let data =
    #|{"meta":{"protocolVersion":"31.1.0","implementation":{"name":"fake-cucumber","version":"123.45.6"},"cpu":{"name":"arm64"},"os":{"name":"darwin","version":"24.5.0"},"runtime":{"name":"Node.js","version":"24.4.1"},"ci":{"name":"GitHub Actions","url":"https://github.com/cucumber-ltd/shouty.rb/actions/runs/154666429","buildNumber":"154666429","git":{"revision":"99684bcacf01d95875834d87903dcb072306c9ad","remote":"https://github.com/cucumber-ltd/shouty.rb.git","branch":"main"}}}}
    #|{"source":{"data":"Feature: Hooks\n  Hooks are special steps that run before or after each scenario's steps.\n\n  Scenario: No tags and a passed step\n    When a step passes\n\n  Scenario: No tags and a failed step\n    When a step fails\n","uri":"samples/hooks/hooks.feature","mediaType":"text/x.cucumber.gherkin+plain"}}
    #|{"gherkinDocument":{"feature":{"tags":[],"location":{"line":1,"column":1},"language":"en","keyword":"Feature","name":"Hooks","description":"  Hooks are special steps that run before or after each scenario's steps.","children":[{"scenario":{"id":"1","tags":[],"location":{"line":4,"column":3},"keyword":"Scenario","name":"No tags and a passed step","description":"","steps":[{"id":"0","location":{"line":5,"column":5},"keyword":"When ","keywordType":"Action","text":"a step passes"}],"examples":[]}},{"scenario":{"id":"3","tags":[],"location":{"line":7,"column":3},"keyword":"Scenario","name":"No tags and a failed step","description":"","steps":[{"id":"2","location":{"line":8,"column":5},"keyword":"When ","keywordType":"Action","text":"a step fails"}],"examples":[]}}]},"comments":[],"uri":"samples/hooks/hooks.feature"}}
    #|{"pickle":{"id":"5","uri":"samples/hooks/hooks.feature","location":{"line":4,"column":3},"astNodeIds":["1"],"tags":[],"name":"No tags and a passed step","language":"en","steps":[{"id":"4","text":"a step passes","type":"Action","astNodeIds":["0"]}]}}
    #|{"pickle":{"id":"7","uri":"samples/hooks/hooks.feature","location":{"line":7,"column":3},"astNodeIds":["3"],"tags":[],"name":"No tags and a failed step","language":"en","steps":[{"id":"6","text":"a step fails","type":"Action","astNodeIds":["2"]}]}}
    #|{"hook":{"id":"8","type":"BEFORE_TEST_CASE","sourceReference":{"uri":"samples/hooks/hooks.ts","location":{"line":3}}}}
    #|{"stepDefinition":{"id":"9","pattern":{"type":"CUCUMBER_EXPRESSION","source":"a step passes"},"sourceReference":{"uri":"samples/hooks/hooks.ts","location":{"line":7}}}}
    #|{"stepDefinition":{"id":"10","pattern":{"type":"CUCUMBER_EXPRESSION","source":"a step fails"},"sourceReference":{"uri":"samples/hooks/hooks.ts","location":{"line":11}}}}
    #|{"hook":{"id":"11","type":"AFTER_TEST_CASE","sourceReference":{"uri":"samples/hooks/hooks.ts","location":{"line":15}}}}
    #|{"testRunStarted":{"id":"12","timestamp":{"seconds":0,"nanos":0}}}
    #|{"testCase":{"id":"13","pickleId":"5","testSteps":[{"id":"14","hookId":"8"},{"id":"15","pickleStepId":"4","stepDefinitionIds":["9"],"stepMatchArgumentsLists":[{"stepMatchArguments":[]}]},{"id":"16","hookId":"11"}],"testRunStartedId":"12"}}
    #|{"testCase":{"id":"17","pickleId":"7","testSteps":[{"id":"18","hookId":"8"},{"id":"19","pickleStepId":"6","stepDefinitionIds":["10"],"stepMatchArgumentsLists":[{"stepMatchArguments":[]}]},{"id":"20","hookId":"11"}],"testRunStartedId":"12"}}
    #|{"testCaseStarted":{"id":"21","testCaseId":"13","timestamp":{"seconds":0,"nanos":1000000},"attempt":0}}
    #|{"testStepStarted":{"testCaseStartedId":"21","testStepId":"14","timestamp":{"seconds":0,"nanos":2000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"21","testStepId":"14","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":3000000}}}
    #|{"testStepStarted":{"testCaseStartedId":"21","testStepId":"15","timestamp":{"seconds":0,"nanos":4000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"21","testStepId":"15","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":5000000}}}
    #|{"testStepStarted":{"testCaseStartedId":"21","testStepId":"16","timestamp":{"seconds":0,"nanos":6000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"21","testStepId":"16","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":7000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"21","timestamp":{"seconds":0,"nanos":8000000},"willBeRetried":false}}
    #|{"testCaseStarted":{"id":"22","testCaseId":"17","timestamp":{"seconds":0,"nanos":9000000},"attempt":0}}
    #|{"testStepStarted":{"testCaseStartedId":"22","testStepId":"18","timestamp":{"seconds":0,"nanos":10000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"22","testStepId":"18","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":11000000}}}
    #|{"testStepStarted":{"testCaseStartedId":"22","testStepId":"19","timestamp":{"seconds":0,"nanos":12000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"22","testStepId":"19","testStepResult":{"message":"Exception in step","exception":{"type":"Error","message":"Exception in step","stackTrace":"Error: Exception in step\nsamples/hooks/hooks.feature:8"},"status":"FAILED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":13000000}}}
    #|{"testStepStarted":{"testCaseStartedId":"22","testStepId":"20","timestamp":{"seconds":0,"nanos":14000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"22","testStepId":"20","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":15000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"22","timestamp":{"seconds":0,"nanos":16000000},"willBeRetried":false}}
    #|{"testRunFinished":{"testRunStartedId":"12","timestamp":{"seconds":0,"nanos":17000000},"success":false}}
  let envelopes = parse_ndjson(data)
  assert_eq(envelopes.length(), 29)
  // Verify Hook type field
  match envelopes[5] {
    Hook(h) => {
      assert_eq(h.id, "8")
      match h.type_ {
        Some(BeforeTestCase) => ()
        _ => panic()
      }
    }
    _ => panic()
  }
  match envelopes[8] {
    Hook(h) =>
      match h.type_ {
        Some(AfterTestCase) => ()
        _ => panic()
      }
    _ => panic()
  }
  // Verify Exception in failed step
  match envelopes[24] {
    TestStepFinished(tsf) => {
      assert_eq(tsf.testStepResult.exception.unwrap().type_, "Error")
      match tsf.testStepResult.status {
        Failed => ()
        _ => panic()
      }
    }
    _ => panic()
  }
}

///|
/// CCK compatibility test: parse the "global-hooks" sample (uses TestRunHookStarted/Finished).
test "cck/global-hooks: parse all envelopes" {
  let data =
    #|{"meta":{"protocolVersion":"31.1.0","implementation":{"name":"fake-cucumber","version":"123.45.6"},"cpu":{"name":"arm64"},"os":{"name":"darwin","version":"24.5.0"},"runtime":{"name":"Node.js","version":"24.4.1"},"ci":{"name":"GitHub Actions","url":"https://github.com/cucumber-ltd/shouty.rb/actions/runs/154666429","buildNumber":"154666429","git":{"revision":"99684bcacf01d95875834d87903dcb072306c9ad","remote":"https://github.com/cucumber-ltd/shouty.rb.git","branch":"main"}}}}
    #|{"source":{"data":"Feature: Global hooks\n  Hooks can be at the test run level, so they run once before or after all test cases.\n\n  AfterAll hooks are executed in reverse order of definition.\n\n  Scenario: A passing scenario\n    When a step passes\n\n  Scenario: A failing scenario\n    When a step fails\n","uri":"samples/global-hooks/global-hooks.feature","mediaType":"text/x.cucumber.gherkin+plain"}}
    #|{"gherkinDocument":{"feature":{"tags":[],"location":{"line":1,"column":1},"language":"en","keyword":"Feature","name":"Global hooks","description":"  Hooks can be at the test run level, so they run once before or after all test cases.\n\n  AfterAll hooks are executed in reverse order of definition.","children":[{"scenario":{"id":"1","tags":[],"location":{"line":6,"column":3},"keyword":"Scenario","name":"A passing scenario","description":"","steps":[{"id":"0","location":{"line":7,"column":5},"keyword":"When ","keywordType":"Action","text":"a step passes"}],"examples":[]}},{"scenario":{"id":"3","tags":[],"location":{"line":9,"column":3},"keyword":"Scenario","name":"A failing scenario","description":"","steps":[{"id":"2","location":{"line":10,"column":5},"keyword":"When ","keywordType":"Action","text":"a step fails"}],"examples":[]}}]},"comments":[],"uri":"samples/global-hooks/global-hooks.feature"}}
    #|{"pickle":{"id":"5","uri":"samples/global-hooks/global-hooks.feature","location":{"line":6,"column":3},"astNodeIds":["1"],"tags":[],"name":"A passing scenario","language":"en","steps":[{"id":"4","text":"a step passes","type":"Action","astNodeIds":["0"]}]}}
    #|{"pickle":{"id":"7","uri":"samples/global-hooks/global-hooks.feature","location":{"line":9,"column":3},"astNodeIds":["3"],"tags":[],"name":"A failing scenario","language":"en","steps":[{"id":"6","text":"a step fails","type":"Action","astNodeIds":["2"]}]}}
    #|{"hook":{"id":"8","type":"BEFORE_TEST_RUN","sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":3}}}}
    #|{"hook":{"id":"9","type":"BEFORE_TEST_RUN","sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":7}}}}
    #|{"stepDefinition":{"id":"10","pattern":{"type":"CUCUMBER_EXPRESSION","source":"a step passes"},"sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":11}}}}
    #|{"stepDefinition":{"id":"11","pattern":{"type":"CUCUMBER_EXPRESSION","source":"a step fails"},"sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":15}}}}
    #|{"hook":{"id":"12","type":"AFTER_TEST_RUN","sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":19}}}}
    #|{"hook":{"id":"13","type":"AFTER_TEST_RUN","sourceReference":{"uri":"samples/global-hooks/global-hooks.ts","location":{"line":23}}}}
    #|{"testRunStarted":{"id":"14","timestamp":{"seconds":0,"nanos":0}}}
    #|{"testRunHookStarted":{"testRunStartedId":"14","id":"15","hookId":"8","timestamp":{"seconds":0,"nanos":1000000}}}
    #|{"testRunHookFinished":{"testRunHookStartedId":"15","timestamp":{"seconds":0,"nanos":2000000},"result":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}}}}
    #|{"testRunHookStarted":{"testRunStartedId":"14","id":"16","hookId":"9","timestamp":{"seconds":0,"nanos":3000000}}}
    #|{"testRunHookFinished":{"testRunHookStartedId":"16","timestamp":{"seconds":0,"nanos":4000000},"result":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}}}}
    #|{"testCase":{"id":"17","pickleId":"5","testSteps":[{"id":"18","pickleStepId":"4","stepDefinitionIds":["10"],"stepMatchArgumentsLists":[{"stepMatchArguments":[]}]}],"testRunStartedId":"14"}}
    #|{"testCase":{"id":"19","pickleId":"7","testSteps":[{"id":"20","pickleStepId":"6","stepDefinitionIds":["11"],"stepMatchArgumentsLists":[{"stepMatchArguments":[]}]}],"testRunStartedId":"14"}}
    #|{"testCaseStarted":{"id":"21","testCaseId":"17","timestamp":{"seconds":0,"nanos":5000000},"attempt":0}}
    #|{"testStepStarted":{"testCaseStartedId":"21","testStepId":"18","timestamp":{"seconds":0,"nanos":6000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"21","testStepId":"18","testStepResult":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":7000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"21","timestamp":{"seconds":0,"nanos":8000000},"willBeRetried":false}}
    #|{"testCaseStarted":{"id":"22","testCaseId":"19","timestamp":{"seconds":0,"nanos":9000000},"attempt":0}}
    #|{"testStepStarted":{"testCaseStartedId":"22","testStepId":"20","timestamp":{"seconds":0,"nanos":10000000}}}
    #|{"testStepFinished":{"testCaseStartedId":"22","testStepId":"20","testStepResult":{"message":"Exception in step","exception":{"type":"Error","message":"Exception in step","stackTrace":"Error: Exception in step\nsamples/global-hooks/global-hooks.feature:10"},"status":"FAILED","duration":{"seconds":0,"nanos":1000000}},"timestamp":{"seconds":0,"nanos":11000000}}}
    #|{"testCaseFinished":{"testCaseStartedId":"22","timestamp":{"seconds":0,"nanos":12000000},"willBeRetried":false}}
    #|{"testRunHookStarted":{"testRunStartedId":"14","id":"23","hookId":"13","timestamp":{"seconds":0,"nanos":13000000}}}
    #|{"testRunHookFinished":{"testRunHookStartedId":"23","timestamp":{"seconds":0,"nanos":14000000},"result":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}}}}
    #|{"testRunHookStarted":{"testRunStartedId":"14","id":"24","hookId":"12","timestamp":{"seconds":0,"nanos":15000000}}}
    #|{"testRunHookFinished":{"testRunHookStartedId":"24","timestamp":{"seconds":0,"nanos":16000000},"result":{"status":"PASSED","duration":{"seconds":0,"nanos":1000000}}}}
    #|{"testRunFinished":{"testRunStartedId":"14","timestamp":{"seconds":0,"nanos":17000000},"success":false}}
  let envelopes = parse_ndjson(data)
  assert_eq(envelopes.length(), 31)
  // Verify BEFORE_TEST_RUN hooks
  match envelopes[5] {
    Hook(h) =>
      match h.type_ {
        Some(BeforeTestRun) => ()
        _ => panic()
      }
    _ => panic()
  }
  // Verify TestRunHookStarted
  match envelopes[12] {
    TestRunHookStarted(trhs) => assert_eq(trhs.hookId, "8")
    _ => panic()
  }
  // Verify TestRunHookFinished
  match envelopes[13] {
    TestRunHookFinished(trhf) =>
      match trhf.result.status {
        Passed => ()
        _ => panic()
      }
    _ => panic()
  }
}
