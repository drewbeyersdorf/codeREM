<p align="center">
  <img src="docs/logo.svg" alt="codeREM" width="700" />
</p>

**Your AI agent's memory decays every day. Dead links, stale facts, broken references. codeREM consolidates it while you sleep.**

codeREM is a memory consolidation system for Claude Code. It runs three phases of analysis on your agent's memory files -- surface cleanup, structural integrity, semantic verification -- then writes what it learned into autobiographical episodes. Like REM sleep for your codebase.

![codeREM demo](docs/demo.svg)

## Why This Exists

Claude Code stores persistent memory in markdown files. Over time, these files accumulate problems:

- File paths that no longer exist
- Relative dates that become meaningless ("last Thursday")
- Duplicate information across files
- Stale facts that contradict current state
- Broken cross-references between memory files

You don't notice until your agent gives you confidently wrong answers based on memory from three weeks ago. codeREM catches these before they compound.

## How It Works

During REM sleep, your brain replays the day's experiences, strengthens useful connections, and prunes what doesn't matter. codeREM does the same thing in three phases:

```
Phase 1: Surface Cleanup          Phase 2: Structural Integrity       Phase 3: Semantic Verification
- Dead path detection              - Cross-reference validation         - Fact vs. current state
- Relative date conversion         - Pointer file verification          - Contradiction detection
- Frontmatter normalization        - Index consistency (MEMORY.md)      - Staleness scoring
- Duplicate detection              - Canonical source alignment         - Recommended deletions
```

Each phase calls Claude with a structured prompt, gets back JSON actions (fix/flag/delete), applies fixes automatically, and git-commits the changes. The dream journal logs everything.

## Quick Start

```bash
# Clone and symlink
git clone https://github.com/drewbeyersdorf/codeREM.git
cd codeREM
chmod +x deep-dream chronicle-writer chronicle-render render-image nightly-dream
ln -s "$(pwd)/deep-dream" ~/.local/bin/deep-dream
ln -s "$(pwd)/nightly-dream" ~/.local/bin/nightly-dream

# Run all three phases
deep-dream

# Run just surface cleanup
deep-dream --surface

# Dry run (see what would change, change nothing)
deep-dream --dry-run
```

## CLI

### `deep-dream` -- the consolidation engine

```
$ deep-dream

  deep-dream -- memory consolidation agent
  =========================================

=== Phase 1: Surface Cleanup ===

[03:00:12] Starting phase 1...
[03:00:12] Assembling context...
[03:00:14] Prompt assembled (387KB). Calling Claude (sonnet)...
[03:12:41] Claude returned 17 actions.
  FIXED labor.md: convert "last Thursday" to "2026-03-20"
  FIXED infrastructure.md: remove dead path ~/projects/workforce-scheduling/
  FIXED team.md: update Saeloun cost from $20K to $12K (transition in progress)
  FLAG [warning] competitive.md: Locale status may be outdated (last updated 2026-03-01)
  ...

[03:12:42] Phase 1 summary: 17 fixes, 3 flags.
[03:12:42] Git commit: phase 1 changes committed.

=== Phase 2: Structural Integrity ===

[03:12:43] Starting phase 2...
  FIXED MEMORY.md: add missing pointer for ops-kpi.md
  FLAG [error] product.md: canonical source ~/vault/methodology-kb/product-menu.md has diverged
  ...

=== Phase 3: Semantic Verification ===

[03:24:01] Starting phase 3...
  FLAG [warning] labor.md: claims 14.9% but QuickBooks shows 15.2% as of last sync
  FLAG [info] strategy.md: displacement thesis section hasn't been updated in 3 weeks
  ...

  =========================================
  Deep Dream Complete
  =========================================
  Fixes applied: 42
  Items flagged: 11
  Journal: memory-backups/dream-journal-2026-03-25.md
  =========================================
```

### `chronicle-writer` -- two-model writing pipeline

Takes dream findings and turns them into autobiographical episodes. Llama (72B on local GPU) generates structured outlines. Claude writes the prose.

```bash
# Write from today's findings
chronicle-writer

# Write for a specific section
chronicle-writer --section ii-the-machine

# Just get the Llama outline, skip Claude
chronicle-writer --llama-only
```

### `render-image` -- GPU illustration generator

SDXL Turbo on a local GPU. 0.3 seconds per image. Five art styles.

```bash
render-image "a frog leaping into a data pipeline" output.png --style silverstein
render-image "memory consolidation as a neural network" cover.png --style sketch
render-image "entropy in a kitchen" entropy.png --style banksy
```

| Style | Aesthetic |
|-------|-----------|
| `silverstein` | Shel Silverstein pen-and-ink line art |
| `banksy` | High-contrast stencil street art |
| `sketch` | Pencil on aged paper, architectural drawing |
| `terminal` | Green-on-black hacker aesthetic |
| `diagram` | Clean technical schematic |

### `chronicle-render` -- scene extraction and illustration

Reads a chronicle episode, extracts 3-5 visual moments, generates illustrations in any style.

```bash
chronicle-render episode.md --style silverstein
chronicle-render episode.md --illustrations-only
chronicle-render --list-styles
```

### `nightly-dream` -- scheduled automation

Systemd timer that runs at 3 AM every night. All three dream phases, then generates one chronicle episode, rotating through sections by day of year.

```bash
# Check timer status
systemctl --user status nightly-dream.timer

# Run manually
nightly-dream

# View last night's log
cat ~/.claude/projects/-home-drew/memory-backups/nightly-dream-$(date +%Y-%m-%d).log
```

## Architecture

```
                        +------------------+
                        |   nightly-dream  |
                        |   (3 AM cron)    |
                        +--------+---------+
                                 |
                    +------------+------------+
                    |                         |
              +-----+------+          +------+-------+
              | deep-dream |          | chronicle-   |
              | (3 phases) |          | writer       |
              +-----+------+          +------+-------+
                    |                        |
           Claude CLI                  +-----+------+
           (sonnet/opus)               |            |
                    |              Llama 72B    Claude CLI
                    |              (local GPU)  (sonnet)
              +-----+------+           |
              | memory dir |     +-----+------+
              | (.md files)|     | chronicles |
              | + git repo |     | (.md files)|
              +-----------+      +-----+------+
                                       |
                                 +-----+------+
                                 | render-    |
                                 | image      |
                                 +-----+------+
                                       |
                                  SDXL Turbo
                                  (local GPU)
```

## What It Produces

Every night, codeREM generates:

1. **Dream journal** -- timestamped log of every fix, flag, and skip across all three phases
2. **Git history** -- one commit per phase, so you can diff or rollback any consolidation run
3. **Chronicle episodes** -- autobiographical short stories that emerge from the day's findings
4. **Illustrations** -- AI-generated art in five distinct styles

The dream journal is your audit trail. The git history is your undo button. The chronicles are the creative output -- a book being written one episode per night, entirely from what the memory system learned that day.

## Requirements

- Claude Code CLI (`claude`) installed and authenticated
- `jq` for JSON parsing
- Python 3.12+ (for prompt assembly and image generation)
- GPU with CUDA support (for render-image and chronicle-render)
- Ollama running locally or on a remote machine (for chronicle-writer)

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Consolidation engine | Bash + Claude CLI |
| Structured output | Claude `--json-schema` |
| Outline generation | Ollama (Qwen 72B) |
| Prose writing | Claude (Sonnet) |
| Image generation | SDXL Turbo via diffusers |
| Scheduling | systemd timers |
| Version control | Git (per-phase commits) |

## License

MIT
