# moonrockz/cucumber-messages

Cucumber Messages protocol types for [MoonBit](https://docs.moonbitlang.com).
Defines the standardized message types used by
[Cucumber](https://cucumber.io/) for representing test execution results.

## Installation

```bash
moon add moonrockz/cucumber-messages
```

## What are Cucumber Messages?

[Cucumber Messages](https://github.com/cucumber/messages) is a message protocol
for representing the results of running Cucumber tests. Messages are exchanged
as [NDJSON](https://ndjson.org/) (newline-delimited JSON) streams -- one JSON
object per line, each wrapped in an `Envelope`.

This decouples Gherkin parsing from test execution, enables real-time result
processing, and reduces memory consumption compared to traditional JSON/XML
formats.

## Message Types

The protocol defines message types wrapped in an `Envelope` discriminated union:

| Category | Message Types |
|----------|--------------|
| **Source & Parsing** | `Source`, `GherkinDocument`, `ParseError` |
| **Test Compilation** | `Pickle` |
| **Glue Definitions** | `StepDefinition`, `Hook`, `ParameterType` |
| **Test Run Lifecycle** | `TestRunStarted`, `TestRunFinished` |
| **Test Case Lifecycle** | `TestCase`, `TestCaseStarted`, `TestCaseFinished` |
| **Step Lifecycle** | `TestStepStarted`, `TestStepFinished` |
| **Hook Lifecycle** | `TestRunHookStarted`, `TestRunHookFinished` |
| **Artifacts** | `Attachment`, `ExternalAttachment` |
| **Metadata** | `Meta`, `Suggestion`, `UndefinedParameterType` |

## Usage

```moonbit
// Deserialize a message from JSON (use your package alias for Envelope, e.g. @cm)
let json = @json.parse(
  "{\"meta\": {\"protocolVersion\": \"27.0.0\", \"implementation\": {\"name\": \"cucumber-moonbit\"}, \"runtime\": {\"name\": \"moonbit\"}, \"os\": {\"name\": \"linux\"}, \"cpu\": {\"name\": \"amd64\"}}}"
) catch { _ => panic() }
let envelope : Envelope = @json.from_json(json) catch { _ => panic() }

// Serialize a message to JSON
let json_value = envelope.to_json()

// NDJSON streaming: parse multiple messages from newline-delimited JSON
let envelopes = @cm.parse_ndjson(ndjson_string) catch { _ => panic() }

// Serialize envelopes to NDJSON
let ndjson = @cm.envelopes_to_ndjson(envelopes)
```

## Compatibility

This library targets **Cucumber Messages protocol v27.0.0**. It is designed to
interoperate with other Cucumber implementations (Java, JavaScript, Ruby,
Python, Go, etc.) via the shared NDJSON format.

## Related Projects

- [moonrockz/gherkin](https://github.com/moonrockz/gherkin) -- Gherkin parser
  for MoonBit (produces `GherkinDocument` messages)
- [cucumber/messages](https://github.com/cucumber/messages) -- Upstream protocol
  definition and multi-language implementations

## License

Apache-2.0
