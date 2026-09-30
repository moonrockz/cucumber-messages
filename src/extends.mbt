// Explicit method promotion for trait implementations.
// MoonBit no longer attaches trait methods to types implicitly.

// --- promoted: kept as regular methods ---

///|
pub extend Attachment with ToJson::{to_json}

///|
pub extend AttachmentContentEncoding with ToJson::{to_json}

///|
pub extend Background with ToJson::{to_json}

///|
pub extend Ci with ToJson::{to_json}

///|
pub extend Comment with ToJson::{to_json}

///|
pub extend DataTable with ToJson::{to_json}

///|
pub extend DocString with ToJson::{to_json}

///|
pub extend Duration with ToJson::{to_json}

///|
pub extend Envelope with ToJson::{to_json}

///|
pub extend Examples with ToJson::{to_json}

///|
pub extend Exception with ToJson::{to_json}

///|
pub extend ExternalAttachment with ToJson::{to_json}

///|
pub extend Feature with ToJson::{to_json}

///|
pub extend FeatureChild with ToJson::{to_json}

///|
pub extend GherkinDocument with ToJson::{to_json}

///|
pub extend Git with ToJson::{to_json}

///|
pub extend Group with ToJson::{to_json}

///|
pub extend Hook with ToJson::{to_json}

///|
pub extend HookType with ToJson::{to_json}

///|
pub extend JavaMethod with ToJson::{to_json}

///|
pub extend JavaStackTraceElement with ToJson::{to_json}

///|
pub extend KeywordType with ToJson::{to_json}

///|
pub extend Location with ToJson::{to_json}

///|
pub extend Meta with ToJson::{to_json}

///|
pub extend ParameterType with ToJson::{to_json}

///|
pub extend ParseError with ToJson::{to_json}

///|
pub extend Pickle with ToJson::{to_json}

///|
pub extend PickleDocString with ToJson::{to_json}

///|
pub extend PickleStep with ToJson::{to_json}

///|
pub extend PickleStepArgument with ToJson::{to_json}

///|
pub extend PickleStepType with ToJson::{to_json}

///|
pub extend PickleTable with ToJson::{to_json}

///|
pub extend PickleTableCell with ToJson::{to_json}

///|
pub extend PickleTableRow with ToJson::{to_json}

///|
pub extend PickleTag with ToJson::{to_json}

///|
pub extend Product with ToJson::{to_json}

///|
pub extend Rule with ToJson::{to_json}

///|
pub extend RuleChild with ToJson::{to_json}

///|
pub extend Scenario with ToJson::{to_json}

///|
pub extend Snippet with ToJson::{to_json}

///|
pub extend Source with ToJson::{to_json}

///|
pub extend SourceMediaType with ToJson::{to_json}

///|
pub extend SourceReference with ToJson::{to_json}

///|
pub extend Step with ToJson::{to_json}

///|
pub extend StepDefinition with ToJson::{to_json}

///|
pub extend StepDefinitionPattern with ToJson::{to_json}

///|
pub extend StepDefinitionPatternType with ToJson::{to_json}

///|
pub extend StepMatchArgument with ToJson::{to_json}

///|
pub extend StepMatchArgumentsList with ToJson::{to_json}

///|
pub extend Suggestion with ToJson::{to_json}

///|
pub extend TableCell with ToJson::{to_json}

///|
pub extend TableRow with ToJson::{to_json}

///|
pub extend Tag with ToJson::{to_json}

///|
pub extend TestCase with ToJson::{to_json}

///|
pub extend TestCaseFinished with ToJson::{to_json}

///|
pub extend TestCaseStarted with ToJson::{to_json}

///|
pub extend TestRunFinished with ToJson::{to_json}

///|
pub extend TestRunHookFinished with ToJson::{to_json}

///|
pub extend TestRunHookStarted with ToJson::{to_json}

///|
pub extend TestRunStarted with ToJson::{to_json}

///|
pub extend TestStep with ToJson::{to_json}

///|
pub extend TestStepFinished with ToJson::{to_json}

///|
pub extend TestStepResult with ToJson::{to_json}

///|
pub extend TestStepResultStatus with ToJson::{to_json}

///|
pub extend TestStepStarted with ToJson::{to_json}

///|
pub extend Timestamp with ToJson::{to_json}

///|
pub extend UndefinedParameterType with ToJson::{to_json}

///|
pub extend NdjsonParseError with Show::{output, to_string}

// --- compatibility: kept only for migration ---

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Attachment with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend AttachmentContentEncoding with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Background with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Ci with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Comment with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend DataTable with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend DocString with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Duration with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Envelope with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Examples with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Exception with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend ExternalAttachment with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Feature with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend FeatureChild with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend GherkinDocument with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Git with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Group with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Hook with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend HookType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend JavaMethod with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend JavaStackTraceElement with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend KeywordType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Location with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Meta with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend ParameterType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend ParseError with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Pickle with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleDocString with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleStep with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleStepArgument with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleStepType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleTable with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleTableCell with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleTableRow with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend PickleTag with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Product with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Rule with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend RuleChild with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Scenario with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Snippet with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Source with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend SourceMediaType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend SourceReference with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Step with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend StepDefinition with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend StepDefinitionPattern with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend StepDefinitionPatternType with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend StepMatchArgument with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend StepMatchArgumentsList with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Suggestion with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TableCell with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TableRow with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Tag with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestCase with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestCaseFinished with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestCaseStarted with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestRunFinished with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestRunHookFinished with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestRunHookStarted with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestRunStarted with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestStep with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestStepFinished with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestStepResult with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestStepResultStatus with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend TestStepStarted with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend Timestamp with @json.FromJson::{from_json}

///|
#deprecated("Use `@json.from_json` instead", skip_current_package=true)
#doc(hidden)
pub extend UndefinedParameterType with @json.FromJson::{from_json}
