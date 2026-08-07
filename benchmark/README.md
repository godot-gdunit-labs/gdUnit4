# Discovery-cache benchmark

`bench_runner.sh` measures the effect of the persistent test-discovery cache
(`settings/test/discovery_cache`) on a target Godot project.

It syncs this repo's `addons/gdUnit4` into the target project, warms the import cache,
then times a **cold** run (discovery cache cleared) against **warm** runs (cache present).
The difference is the discovery cost the cache removes; test execution time is unaffected.

## Usage

```bash
benchmark/bench_runner.sh \
  --godot "/path/to/godot" \
  --project ../my-project \
  --iterations 5
```

Options:

- `--godot` — path to the Godot binary (required)
- `--project` — path to the target project containing a `project.godot` (required)
- `--iterations` — number of warm runs to median over (default 5)
- `--filter` — test path to run (default `res://test/`)
- `--no-sync` — do not copy the addon into the target first

## Example result

Measured on a project of 629 tests across 89 suites (Godot 4.7.1, macOS):

| Run | Discovery |
| --- | ---: |
| Cold (builds cache) | ~1580 ms |
| Warm | ~14 ms |

About 1.57 s saved per warm run, scaling with the number of suites.
