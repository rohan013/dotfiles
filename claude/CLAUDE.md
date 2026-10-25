# Working rules

## Current context
Right now I'm doing a one-day working session in a codebase I haven't seen before: a known
starter bug, then open-ended work, ending with a presentation/demo of what we did. Favor
depth, clear reasoning and evidence over volume.

## Layout
The directory containing this file is the work directory. Repos and their worktrees are
cloned into it, and notes live in its notes/ folder.

## Defaults
- Reproduce a bug before fixing it. If you can't reproduce it, say so. Don't guess-fix.
- Never push to main, and never merge PRs. I merge.
- Run the project's checks (build, typecheck, lint, tests: whatever the repo uses) on the
  code you changed before calling a change done or pushing it.
- Tell me when you're guessing. Separate "verified" from "likely".
- Local, reversible actions are fine without asking. Pushing, opening PRs and commenting
  are my call. Check with me before anything that could lose work.

## Notes (notes/ in the work directory)
- architecture.md: components and where they live, how they connect, the data model, one
  traced request, and how to run it.
- findings.md: bugs, doc errors and ideas, in priority order, with evidence.
- log.md: append-only, timestamped: what we did, why, what we ruled out, and where you
  were wrong or I corrected you. Update it after each finding, decision or PR.
- evidence/: raw outputs, with the exact command at the top of each file. Before changing
  anything performance- or behavior-related, record a baseline here first, then the after.

## Starting in a new repo
When I ask you to orient yourself or look around a repo, don't change code:
1. Check the toolchain the repo needs and get it running with the repo's own scripts. If
   something is missing, install it; if that needs sudo, give me the command.
2. Map the components, how they connect, and the data model. Trace one real request
   through the system end to end.
3. Note mismatches between the docs and reality.
4. Write architecture.md and findings.md, then reply in one screen: running or not, how to
   run it, top findings.

## Parallel sessions
Assume other Claude sessions are working in this repo at the same time.
1. Before starting, read notes/sessions.md and run `git worktree list`.
2. Read-only work happens in the main checkout. For changes, always create a new worktree
   of your own (`git worktree add ../<repo>-<task> -b <branch> main`). Never reuse an
   existing one. Add a line to sessions.md with your branch, worktree and ports, and mark
   it done when finished.
3. If you run anything, use non-default ports and confirm the processes actually got them.
4. Never stop or restart shared services, and ask before resetting shared data.

## PRs
- Commit messages: under 20 words, saying broadly what the change fixes or adds. If it
  covers several things, list each one briefly. Skip minor items like typos or small
  refactors.
- Create PRs as drafts (`gh pr create --draft`).
