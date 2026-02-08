# Cucumber Messages MoonBit Port — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Port the Cucumber Messages protocol (v27) to MoonBit: type definitions aligned to upstream JSON Schema, JSON serialization (ToJson/FromJson), and NDJSON streaming utilities, following the project’s functional design principles.

**Architecture:** Types live in `src/` as MoonBit structs and enums. Shared primitives (Location, Timestamp, Duration, small enums) are defined first; then message payload types in dependency order; finally the Envelope sum type and custom (de)serialization. JSON keys match upstream (camelCase). Optional fields use `Option[T]`; required fields are non-optional. Strict TDD: one failing test per type/behavior, then minimal implementation, then refactor.

**Tech Stack:** MoonBit, moonbitlang/core (json), upstream cucumber/messages jsonschema (reference).

---

## Functional principles (non-negotiable)

- **ADTs:** Envelope as enum (one variant per message type). Use enums for fixed sets (e.g. AttachmentContentEncoding, SourceMediaType).
- **Make invalid states unrepresentable:** Types prevent illegal combinations; avoid “stringly” status fields.
- **Avoid primitive obsession:** Location, Timestamp, Duration as structs; prefer domain types over raw String/Int where it adds clarity.
- **Immutability:** All structs immutable; no `mut` unless clearly necessary.
- **Total functions:** FromJson returns `Result` or uses `raise` with typed errors; no panic for bad input where avoidable.
- **TDD:** Red → Green → Refactor per behavior; tests in `*_test.mbt` next to implementation.

---

## Phase 1: Primitives and shared types

Dependency-free types used by many messages. Order: enums (no deps), then Location, Timestamp, Duration.

### Task 1.1: Location

**Files:**
- Create: `src/location.mbt`
- Create: `src/location_test.mbt`
- Modify: `src/lib.mbt` (re-export)

**Steps:**
1. Write failing test: decode `{"line": 1}` and `{"line": 2, "column": 3}`; encode round-trip.
2. Run: `mise run test:unit` — fail (type missing).
3. Implement: struct `Location { line: Int, column: Option[Int] }` with `derive(ToJson, FromJson)`. Schema: line required (min 1), column optional (min 1).
4. Run tests — pass.
5. Commit: `feat(types): add Location with JSON (de)serialization`

### Task 1.2: Timestamp

**Files:**
- Create: `src/timestamp.mbt`
- Create: `src/timestamp_test.mbt`
- Modify: `src/lib.mbt`

**Steps:** Same TDD cycle. Struct `Timestamp { seconds: Int, nanos: Int }`; required both; nanos 0..999_999_999. Tests: from_json / to_json round-trip.

### Task 1.3: Duration

**Files:**
- Create: `src/duration.mbt`
- Create: `src/duration_test.mbt`
- Modify: `src/lib.mbt`

**Steps:** Struct `Duration { seconds: Int, nanos: Int }` (same constraints as Timestamp). TDD as above.

### Task 1.4: SourceMediaType enum

**Files:**
- Create: `src/source_media_type.mbt`
- Create: `src/source_media_type_test.mbt`
- Modify: `src/lib.mbt`

**Steps:** Enum for `text/x.cucumber.gherkin+plain` and `text/x.cucumber.gherkin+markdown`. Serialize as string; deserialize from string. TDD.

---

## Phase 2: Meta and Envelope (first variant)

Get one full Envelope variant (Meta) working so the Envelope pattern is established.

### Task 2.1: Product, Ci, Git (Meta sub-types)

**Files:**
- Create: `src/meta.mbt` (Product, Ci, Git, Meta)
- Create: `src/meta_test.mbt`
- Modify: `src/lib.mbt`

**Steps:**
1. Tests: decode sample Meta JSON (protocolVersion, implementation.name, runtime, os, cpu; optional ci with name, url, git.remote/revision).
2. Implement Product { name: String, version: Option[String] }, Ci, Git, Meta with derive(ToJson, FromJson).
3. Run tests, commit: `feat(types): add Meta and nested Product, Ci, Git`

### Task 2.2: Envelope enum and Meta variant

**Files:**
- Create: `src/envelope.mbt`
- Create: `src/envelope_test.mbt`
- Modify: `src/lib.mbt`

**Steps:**
1. Test: parse `{"meta": { "protocolVersion": "27.0.0", "implementation": {"name": "x"}, "runtime": {"name": "y"}, "os": {"name": "z"}, "cpu": {"name": "w"} }}` → Envelope::Meta(...); then to_json round-trip.
2. Implement enum Envelope with variant Meta(Meta). Custom FromJson: check object keys (meta, source, ...), dispatch to Meta when "meta" present. Custom ToJson: emit single key per variant.
3. Run tests, commit: `feat(envelope): add Envelope enum with Meta variant and JSON (de)serialization`

---

## Phase 3: Remaining message types (in dependency order)

Add types so that every Envelope variant can be (de)serialized. Order below respects refs in schema.

### Task 3.1: Source, ParseError

**Files:** `src/source.mbt`, `src/source_test.mbt`, `src/parse_error.mbt`, `src/parse_error_test.mbt`; add SourceReference if needed by ParseError. Wire into Envelope.

### Task 3.2: Attachment, ExternalAttachment

**Files:** `src/attachment.mbt` (and AttachmentContentEncoding enum), `src/external_attachment.mbt`, tests, Envelope.

### Task 3.3: Hook, StepDefinition, ParameterType, Suggestion, UndefinedParameterType

**Files:** Hook, StepDefinition (with StepDefinitionPattern, StepDefinitionPatternType), ParameterType, Suggestion (Snippet), UndefinedParameterType; tests; Envelope.

### Task 3.4: GherkinDocument (AST)

**Files:** `src/gherkin_document.mbt` (Feature, FeatureChild, Rule, RuleChild, Scenario, Step, Examples, Background, Comment, Tag, TableRow, TableCell, DataTable, DocString, Location refs). Large but mechanical from schema; split into sub-modules if needed. Tests: minimal fixture round-trip. Envelope.

### Task 3.5: Pickle

**Files:** Pickle, PickleStep, PickleTag, PickleStepArgument, PickleTable, PickleTableRow, PickleTableCell, PickleDocString; enums (e.g. PickleStepType); tests; Envelope.

### Task 3.6: TestCase and test steps

**Files:** TestStep, StepMatchArgument, Group, StepMatchArgumentsList; TestCase; tests; Envelope.

### Task 3.7: Lifecycle and result types

**Files:** TestRunStarted, TestRunFinished, TestCaseStarted, TestCaseFinished, TestStepStarted, TestStepFinished, TestRunHookStarted, TestRunHookFinished; TestStepResult (with status enum), Exception; tests; Envelope.

---

## Phase 4: NDJSON streaming

### Task 4.1: Read NDJSON stream

**Files:** `src/ndjson.mbt`, `src/ndjson_test.mbt`

**Steps:** Function that takes a source of lines (e.g. `Iter[String]` or callback) and yields `Result[Envelope, ParseError]` per line (parse JSON, then Envelope::from_json). TDD with sample NDJSON file.

### Task 4.2: Write NDJSON stream

**Files:** Same module.

**Steps:** Function that takes a sink and writes envelopes as one JSON line per envelope. TDD.

---

## Phase 5: Fixtures and polish

### Task 5.1: Test fixtures

**Files:** `tests/*.ndjson` (or under `src/` if preferred) — at least one line per Envelope variant from upstream testdata or hand-crafted.

### Task 5.2: Interface and docs

**Files:** `src/lib.mbt` — re-export public types and NDJSON helpers; ensure `moon info && moon fmt`; update README examples if needed.

---

## Implementation notes (session 2025-02-07)

- **Tests**: Black-box tests (`_test.mbt`) cannot reference the package under test's types by name (module path/alias issues). Use **in-module tests** in `lib.mbt` for types that live in lib so tests can reference `Location`, `Timestamp`, etc. directly. For types in other modules, either add tests in lib that use `module.Type` or use white-box tests and the package alias.
- **Phase 1 (done)**: Location, Timestamp, Duration, SourceMediaType implemented in `src/lib.mbt` with JSON (de)serialization and tests.
- **Phase 2 (done)**: Product, Git, Ci, Meta and Envelope (Meta variant) are in `src/lib.mbt`. Envelope has custom `FromJson`/`ToJson` (dispatch on object key). Decode via `@json.from_json(json)` with type `Envelope`; encode via `envelope.to_json()`. Build Json object for ToJson using `Map[String, Json]` and `o.to_json()`.
- **Phase 3 (done)**: All 21 Envelope variants implemented. Types added: SourceMediaType (custom string enum), Source, SourceReference (+ JavaMethod, JavaStackTraceElement), ParseError, TestRunStarted, TestRunFinished, UndefinedParameterType, TestCaseStarted, TestCaseFinished, TestStepStarted, TestStepFinished, Exception, TestStepResult (+ TestStepResultStatus), AttachmentContentEncoding, Attachment, ExternalAttachment, HookType, Hook, StepDefinitionPatternType, StepDefinitionPattern, StepDefinition, ParameterType, Snippet, Suggestion, TestRunHookStarted, TestRunHookFinished, GherkinDocument AST (Feature, Scenario, Step, Background, Examples, Rule, Comment, Tag, TableRow, TableCell, DataTable, DocString, KeywordType, FeatureChild, RuleChild), Pickle (PickleStep, PickleTag, PickleStepArgument, PickleTable, PickleDocString, PickleStepType), TestCase (TestStep, Group, StepMatchArgument, StepMatchArgumentsList). Exception uses custom FromJson/ToJson to map `type_` field to JSON key `"type"`.
- **Phase 4 (done)**: NDJSON streaming utilities: `parse_ndjson_line`, `Envelope::to_ndjson_line`, `parse_ndjson`, `envelopes_to_ndjson`. 4 NDJSON-specific tests.
- **Phase 5 (done)**: NDJSON test fixture file at `tests/all_variants.ndjson` with 23 lines covering all 21 Envelope variant types. Integration test `fixture all_variants ndjson roundtrip` parses and round-trips the entire fixture. README updated with NDJSON usage examples.
- **Total**: 46 passing tests. All code in `src/lib.mbt`.
- **MoonBit Option serialization note**: `Option[T].to_json()` serializes `Some(x)` as `[x]` (array wrapper). Types using `derive(ToJson, FromJson)` handle this consistently. Custom `ToJson`/`FromJson` impls (like Exception) must emit/consume raw values to match upstream JSON schema.
- **Status**: All 5 phases complete. The library implements all 21 Cucumber Messages protocol v27 Envelope variants with JSON (de)serialization and NDJSON streaming.

## Execution order summary

1. Phase 1 (Location → Timestamp → Duration → SourceMediaType)
2. Phase 2 (Meta + Envelope with Meta)
3. Phase 3 (remaining messages in dependency order)
4. Phase 4 (NDJSON)
5. Phase 5 (fixtures, exports, docs)

Each task: write failing test → run test → implement → run test → commit.
