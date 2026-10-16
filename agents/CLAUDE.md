# CLAUDE.md

This file defines my default preferences for working together across all repositories.

---

## Code Style

### General
- Prefer readability over cleverness.
- Keep solutions simple and maintainable.
- Make the smallest change that solves the problem.
- Follow the existing project's conventions.
- Avoid unnecessary abstractions and premature optimization.
- Prefer explicit code over implicit behavior.

### Structure
- Keep functions focused on a single responsibility.
- Avoid deeply nested logic where possible.
- Reuse existing utilities instead of duplicating code.
- Keep files organized and cohesive.

### Comments
- Explain *why*, not *what*.
- Document public APIs, non-obvious behavior, complex logic and important invariants. 
- Follow the project's documentation conventions.
- Remove stale or redundant comments.
- Never add comments referencing implementation plans, development phases, conversations or AI instructions.
- Keep inline comments concise, ideally one line and at most 1-2 lines when necessary.
- Never add comments, docstrings, or TODOs merely to narrate implementation progress or describe planned future work.

### Error Handling
- Fail explicitly rather than silently hiding failures.
- Return meaningful errors and preserve useful error context.
- Catch exceptions only when they can be handled or meaningfully enriched.
- Add logs for important failures, external interactions, and state transitions. 
- Follow existing logging conventions; avoid noisy or redundant logs.
- Never log secrets or sensitive information.

### Performance
- Consider algorithmic complexity.
- Avoid unnecessary database queries.
- Prefer measurable optimizations over speculative ones.

### SQL
- Write readable queries.
- Think about indexes and execution plans.
- Optimize only after understanding the bottleneck.

---

## Environment

- Primary OS: macOS (Apple Silicon)
- Multiple Linux-like tools installed -> kitty, zsh, nvim, yazi, yabai, sketchybar, fzf, atuin, zoxide, eza, bat, obsidian 
- Shell: zsh
- Terminal: kitty
- Editor: Neovim/VS-Code with Claude extension

Prefer terminal-first workflows whenever possible.

---

## How I like to work

### Before coding
- Understand the problem and inspect the relevant code before implementing.
- Read applicable repository instructions and conventions.
- Inspect Git status and existing changes before editing.
- Ask questions when ambiguity materially affects correctness; otherwise, state reasonable assumptions and proceed.
- Explain meaningful tradeoffs when multiple approaches exist.

### While coding
- Think through edge cases.
- Follow the existing architecture.
- Keep changes focused and minimal.
- Preserve backwards compatibility unless told otherwise.

### Debugging
- Find the root cause, not just the symptom.
- Explain why the issue occurred.
- Consider how to prevent recurrence when appropriate.
- Add targeted logging when it improves diagnosis, following existing conventions.

### Communication
- Be concise.
- Don't over-explain basic concepts.
- Tell me if you think there's a better approach.
- Challenge my assumptions if they're technically unsound.

### Git
- Write meaningful commit messages using Conventional Commits when compatible with project conventions.
- Read-only Git operations are permitted by default.
- Never stage, commit, or push changes, under any circumstances, unless I explicitly request the specific action.
- Never rebase, amend, reset, clean, or discard changes without explicit permission.
- Preserve existing staged, unstaged, and untracked user changes.
- Edit and verify freely within the requested scope.

### Verification
- Do not run commands in the terminal. After every implementation task/change, create or update `execution.md` in the repo root, with commands needed to verify the change, their purpose, and expected results. I will review and execute them manually.
- Do not write or run unit, integration, or other automated tests unless I explicitly request them.
- Add all Markdown files to `.gitignore` except 'README.md', preserving existing ignore rules. Keep planning, execution, and communication documents local and untracked.
- If working in an open-source repository that I do not own, do not follow any of the above verification rules. Follow the repository's contribution guidelines and conventions instead.

---

## My Toolchain

### Languages
- Python
- TypeScript
- JavaScript
- C++
- Java
- Go
- Rust
- SQL
- Bash

### Backend
- FastAPI
- Node.js
- Express
- Spring Boot

### Frontend
- React
- Next.js

### Databases
- PostgreSQL
- MySQL
- MongoDB

### Infrastructure
- Docker
- Kubernetes
- AWS 

### Development
- Git
- Neovim
- VS Code
- Claude

---

## Never Do

- Never use sudo without asking me first.
- Never install global npm packages without confirming.
- Never create commits unless I explicitly ask you to commit.
- Do not introduce new dependencies without explaining why they are needed, considering existing alternatives, and obtaining my explicit approval.
- Never make large architectural changes without discussing them first.
- Never change unrelated code while fixing an issue.
- Never assume business logic—ask if unsure.

---

## Context About Me

- I am a recent Computer Science graduate and am currently a junior-level Software Developer (SDE-1)
- Assume I'm comfortable with intermediate-to-advanced programming concepts.
- Skip explaining basic syntax unless I ask.
- Focus on architecture, performance, maintainability, and tradeoffs.
- I prefer understanding *why* a solution works, not just *what* to write.
- I value pragmatic engineering over theoretical perfection.
- I usually prefer CLI solutions over GUI instructions.
- Assume code is intended for production unless I say otherwise.
- I appreciate honest technical feedback—even if it contradicts my initial approach.
- If there's a significantly better approach, suggest it and explain why.
- Default to modern language features and current best practices.
- When multiple solutions exist, recommend one and briefly explain the tradeoffs.
