# AGENTS.md: benchmark feature

## Documents

Earlier document wins on conflicts.

| Document                                         | Content                                              | Status            |
| ------------------------------------------------ | ---------------------------------------------------- | ----------------- |
| [api-specification.md](api-specification.md)     | User-visible behavior                                | Binding           |
| [technical-design.md](technical-design.md)       | Implementation                                       | Binding           |
| [implementation-plan.md](implementation-plan.md) | Steps with design sections and tests                 | Binding for order |
| [analysis.md](analysis.md)                       | Script profiler and debugger facts, `GD-1248` probes | Background        |

## Rules

- Don't change the specification alone. If it can't work, stop and ask the user with facts.
- Measure before claiming timings. Probes in the scratchpad only, results with Godot version into the design.

## Document upkeep

- One fact, one document: behavior in the specification, implementation in the design, order and tests in the plan.
  Others refer by section.
- User decisions update all affected documents in the same change.
- Finished steps get their PR in the plan.
- Name only GdUnit4 and Godot, no other tools.
- New documents get a row in the table.
- Keep it short, the documents are loaded into LLM context.
