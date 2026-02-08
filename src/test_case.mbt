///|
/// Group: capture group from step matching.
pub struct Group {
  children : Array[Group]?
  start : Int?
  value : String?
} derive(ToJson, FromJson)

///|
/// StepMatchArgument: argument from step matching.
pub struct StepMatchArgument {
  group : Group
  parameterTypeName : String?
} derive(ToJson, FromJson)

///|
/// StepMatchArgumentsList: list of step match arguments.
pub struct StepMatchArgumentsList {
  stepMatchArguments : Array[StepMatchArgument]
} derive(ToJson, FromJson)

///|
/// TestStep: a step in a test case.
pub struct TestStep {
  id : String
  hookId : String?
  pickleStepId : String?
  stepDefinitionIds : Array[String]?
  stepMatchArgumentsLists : Array[StepMatchArgumentsList]?
} derive(ToJson, FromJson)

///|
/// TestCase: a test case (compiled from a pickle).
pub struct TestCase {
  id : String
  pickleId : String
  testSteps : Array[TestStep]
  testRunStartedId : String?
} derive(ToJson, FromJson)

///|
test "test case roundtrip" {
  let raw = "{\"id\":\"tc1\",\"pickleId\":\"p1\",\"testSteps\":[{\"id\":\"ts1\",\"pickleStepId\":\"ps1\",\"stepDefinitionIds\":[\"sd1\"]}]}"
  let json = @json.parse(raw) catch { _ => panic() }
  let tc : TestCase = @json.from_json(json) catch { _ => panic() }
  assert_eq(tc.id, "tc1")
  assert_eq(tc.pickleId, "p1")
  assert_eq(tc.testSteps.length(), 1)
  assert_eq(tc.testSteps[0].id, "ts1")
  let back : TestCase = @json.from_json(tc.to_json()) catch { _ => panic() }
  assert_eq(back.id, tc.id)
}

///|
test "test case with step match arguments roundtrip" {
  let raw = "{\"id\":\"tc2\",\"pickleId\":\"p2\",\"testSteps\":[{\"id\":\"ts2\",\"pickleStepId\":\"ps2\",\"stepDefinitionIds\":[\"sd2\"],\"stepMatchArgumentsLists\":[{\"stepMatchArguments\":[{\"group\":{\"start\":10,\"value\":\"42\",\"children\":[]},\"parameterTypeName\":\"int\"}]}]}]}"
  let json = @json.parse(raw) catch { _ => panic() }
  let tc : TestCase = @json.from_json(json) catch { _ => panic() }
  guard tc.testSteps[0].stepMatchArgumentsLists is Some(lists)
  assert_eq(lists.length(), 1)
  assert_eq(lists[0].stepMatchArguments.length(), 1)
  assert_eq(lists[0].stepMatchArguments[0].group.value, Some("42"))
  assert_eq(lists[0].stepMatchArguments[0].group.start, Some(10))
  assert_eq(lists[0].stepMatchArguments[0].parameterTypeName, Some("int"))
  let back : TestCase = @json.from_json(tc.to_json()) catch { _ => panic() }
  guard back.testSteps[0].stepMatchArgumentsLists is Some(lists2)
  assert_eq(lists2[0].stepMatchArguments[0].group.value, Some("42"))
}
