# Claude Skills

A personal collection of Claude Code skills and OMC (oh-my-claudecode) workflows — versioned here to stay in sync across devices.

## Overview

This repo is the single source of truth for all Claude skills on all machines.

```
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

---

## Folder Structure

```
~/.claude/skills/               ← this repo (global skills directory)
├── skill-creator/              ← loaded by Claude ✓
├── omc-reference/              ← loaded by Claude ✓
│
├── omc/                        ← reference copies of OMC built-in skills
│   ├── autopilot/              │  (loaded by OMC from its own plugin path,
│   ├── ralph/                  │   not from here — for versioning only)
│   └── ...
│
├── .gitignore
└── README.md
```

> **How Claude discovers skills:** Claude loads any folder with a `SKILL.md` directly inside `~/.claude/skills/<name>/SKILL.md`. Skills must be at the **root level** of this directory — nested subfolders won't be auto-loaded.
>
> **OMC skills** (`omc/`) are loaded by oh-my-claudecode from `~/.claude/plugins/marketplaces/omc/skills/`. The copies here are for versioning and reference only.

---

## Quick Start (new machine)

```bash
# One-command bootstrap — installs everything below automatically
bash <(curl -fsSL https://raw.githubusercontent.com/bingcheng45/claude-skills/main/bootstrap.sh)
```

After bootstrap: **restart Claude Code**, run `/setup`, then `/oh-my-claudecode:omc-doctor`.

---

## Full Environment Setup (manual steps)

New Claude instances should verify all components are installed:

### 1. Skills (this repo)

```bash
# Check
ls ~/.claude/skills | wc -l   # should show 100+

# Install
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills

# Upgrade
cd ~/.claude/skills && git pull
```

Then restart Claude Code — skills are loaded at startup.

### 2. oh-my-claudecode (OMC) — multi-agent orchestration

**Step A**: Add the marketplace to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "omc": {
      "source": { "source": "github", "repo": "Yeachan-Heo/oh-my-claudecode" }
    }
  },
  "enabledPlugins": {
    "oh-my-claudecode@omc": true
  }
}
```

**Step B**: Restart Claude Code and run `/setup` to download and build the plugin.

**Step C**: Install the OMC CLI (required for HUD session stats):

```bash
npm install -g oh-my-claude-sisyphus@latest
omc update   # sync any version drift
```

**Step D**: Add the OMC config block to `~/.claude/CLAUDE.md`. Either run `/oh-my-claudecode:omc-setup` inside Claude Code, or append `config/CLAUDE-omc-block.md` from this repo manually.

**Step E**: Install the HUD statusline script:

```bash
mkdir -p ~/.claude/hud
cp ~/.claude/skills/config/omc-hud.mjs ~/.claude/hud/omc-hud.mjs
```

Then add to `~/.claude/settings.json`:

```json
"statusLine": {
  "type": "command",
  "command": "node ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hud/omc-hud.mjs"
}
```

Check install is healthy: `/oh-my-claudecode:omc-doctor`

OMC provides `/autopilot`, `/ralph`, `/ultrawork`, `/team`, `/deep-interview`, and 19 specialized agents (architect, executor, planner, researcher, etc.).

### 3. RTK — Rust Token Killer (~80% token savings on bash output)

```bash
brew install rtk
rtk init -g --auto-patch   # installs hook + RTK.md globally
rtk gain                   # verify token savings
```

### 4. everything-claude-code (ECC) — 47 agents + language rules

```bash
# Clone, copy agents and rules, then add new skills
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git /tmp/ecc
cp -r /tmp/ecc/agents ~/.claude/agents
cp -r /tmp/ecc/rules ~/.claude/rules
# Copy only skills not already present
for d in /tmp/ecc/skills/*/; do
  name=$(basename "$d")
  [ ! -d ~/.claude/skills/$name ] && cp -r "$d" ~/.claude/skills/$name
done
rm -rf /tmp/ecc
```

Provides: 47 subagents (`~/.claude/agents/`), language rules for common/swift/typescript/python/go/etc (`~/.claude/rules/`), and additional skills.

### 5. Claude Island — Dynamic Island notifications for macOS

macOS menu bar app that shows Claude Code activity, permission prompts, and chat history over the MacBook notch.

```bash
# Download and install
curl -L https://github.com/farouqaldori/claude-island/releases/download/v1.2/ClaudeIsland-1.2.dmg -o /tmp/ClaudeIsland.dmg
hdiutil attach /tmp/ClaudeIsland.dmg
cp -r "/Volumes/Claude Island/Claude Island.app" /Applications/
hdiutil detach "/Volumes/Claude Island"
rm /tmp/ClaudeIsland.dmg
```

Then **open Claude Island from /Applications** — it auto-installs the required hooks into `~/.claude/hooks/` on first launch. Requires macOS 15.6+.

> **tmux note**: Claude Island's messaging feature requires Claude Code to run inside tmux. Start with `tmux new-session` before launching `claude`.

---

## Configuration Reference (`config/`)

Reference files for the full working configuration live in `config/`:

| File | Purpose |
|------|---------|
| `config/settings.json` | Complete `~/.claude/settings.json` template with correct permissions |
| `config/CLAUDE-omc-block.md` | OMC block to append to `~/.claude/CLAUDE.md` |
| `config/omc-hud.mjs` | HUD statusline script for `~/.claude/hud/omc-hud.mjs` |

---

## Gotchas & Fixes

These are real issues encountered during setup — read before troubleshooting:

### `[API err]` in OMC HUD statusline

Two separate root causes, both needed:

1. **OMC CLI not installed** → `npm install -g oh-my-claude-sisyphus@latest`
2. **`<!-- OMC:START -->` block missing from `~/.claude/CLAUDE.md`** → run `/oh-my-claudecode:omc-setup` or append `config/CLAUDE-omc-block.md`

### HUD shows "NOT configured" or no session stats

The OMC plugin was downloaded but not built. Fix:

```bash
# Find the plugin cache dir
PLUGIN_DIR=$(ls -d ~/.claude/plugins/cache/omc/oh-my-claudecode/*/  | tail -1)
cd "$PLUGIN_DIR" && npm install && npm run build
```

### `Permission denied` — Claude can't write outside project directory

Two bugs in `settings.json` cause this:

1. **Wrong `defaultMode`**: `"dontAsk"` silently denies without prompting. Use `"bypassPermissions"` instead.
2. **Invalid wildcard syntax**: `"Bash(*)"` is not valid. Use bare tool names: `"Bash"`, `"Write"`, etc.
3. **Missing `additionalDirectories`**: Claude can't write to `~/.claude/` unless listed here.

Correct permissions block:

```json
"permissions": {
  "defaultMode": "bypassPermissions",
  "allow": ["Bash", "Read", "Write", "Edit", "Glob", "Grep",
            "WebFetch", "WebSearch", "NotebookRead", "NotebookEdit",
            "TodoRead", "TodoWrite"],
  "additionalDirectories": ["/Users/your-username/.claude"]
}
```

See `config/settings.json` for the complete working template.

### OMC version drift warning at session start

```bash
omc update   # syncs CLAUDE.md OMC block to match installed plugin version
```

### Claude Island — "open in tmux to enable messaging"

Claude Island's messaging (send messages to Claude from Dynamic Island) requires a tmux session. Launch Claude Code this way:

```bash
tmux new-session -s claude
# then inside tmux:
claude
```

---

## Syncing Across Devices

```bash
# Pull latest on another device
cd ~/.claude/skills && git pull

# After adding or modifying a skill locally
cd ~/.claude/skills
git add <skill-folder>
git commit -m "feat: add/update <skill-name>"
git push
```

---

## Personal Skills

These live at the root and are auto-loaded by Claude globally:

| Skill | Description | Trigger |
|-------|-------------|---------|
| [skill-creator](./skill-creator/) | Create, test, benchmark, and optimize new Claude skills | "create a skill for X", "make a skill that does X" |
| [omc-reference](./omc-reference/) | OMC agent catalog and tools reference | Auto-loads when orchestrating agents |
| [explain](./explain/) | Explains any concept using Feynman first-principles style — clear, analogy-driven, no jargon | "explain X", "ELI5 X", "/explain X" |
| [learning-goal](./learning-goal/) | Structured goal-setting using MCII — visualize outcomes, anticipate obstacles, build if-then plans | "set a learning goal", "help me plan what to learn" |
| [learning-opportunities](./learning-opportunities/) | Offers learning exercises after architectural work to deepen understanding of design choices | Auto-triggers after features/refactors, "help me understand this" |
| [agent-harness-construction](./agent-harness-construction/) | Design and optimize AI agent action spaces, tool definitions, and observation formatting for higher completion rates. | "build agent harness construction" |
| [agentic-engineering](./agentic-engineering/) | Operate as an agentic engineer using eval-first execution, decomposition, and cost-aware model routing. | "use agentic engineering" |
| [ai-first-engineering](./ai-first-engineering/) | Engineering operating model for teams where AI agents generate a large share of implementation output. | "use ai first engineering" |
| [ai-regression-testing](./ai-regression-testing/) | Regression testing strategies for AI-assisted development. Sandbox-mode API testing without database dependencies, automated bug-check workflows, and patterns to catch AI blind spots where the same model writes and reviews code. | "run ai regression testing" |
| [android-clean-architecture](./android-clean-architecture/) | Clean Architecture patterns for Android and Kotlin Multiplatform projects — module structure, dependency rules, UseCases, Repositories, and data layer patterns. | "apply android clean architecture" |
| [api-design](./api-design/) | REST API design patterns including resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs. | "build api design" |
| [article-writing](./article-writing/) | Write articles, guides, blog posts, tutorials, newsletter issues, and other long-form content in a distinctive voice derived from supplied examples or brand guidance. Use when the user wants polished written content longer than a paragraph, especially when voice consistency, structure, and credibility matter. | "write article writing" |
| [autonomous-loops](./autonomous-loops/) | Patterns and architectures for autonomous Claude Code loops — from simple sequential pipelines to RFC-driven multi-agent DAG systems. | "use autonomous loops" |
| [backend-patterns](./backend-patterns/) | Backend architecture patterns, API design, database optimization, and server-side best practices for Node.js, Express, and Next.js API routes. | "apply backend patterns" |
| [blueprint](./blueprint/) | >- | "use blueprint" |
| [carrier-relationship-management](./carrier-relationship-management/) | > | "use carrier relationship management" |
| [claude-api](./claude-api/) | Anthropic Claude API patterns for Python and TypeScript. Covers Messages API, streaming, tool use, vision, extended thinking, batches, prompt caching, and Claude Agent SDK. Use when building applications with the Claude API or Anthropic SDKs. | "use claude api" |
| [claude-devfleet](./claude-devfleet/) | Orchestrate multi-agent coding tasks via Claude DevFleet — plan projects, dispatch parallel agents in isolated worktrees, monitor progress, and read structured reports. | "use claude devfleet" |
| [clickhouse-io](./clickhouse-io/) | ClickHouse database patterns, query optimization, analytics, and data engineering best practices for high-performance analytical workloads. | "use clickhouse io" |
| [coding-standards](./coding-standards/) | Universal coding standards, best practices, and patterns for TypeScript, JavaScript, React, and Node.js development. | "apply coding standards" |
| [compose-multiplatform-patterns](./compose-multiplatform-patterns/) | Compose Multiplatform and Jetpack Compose patterns for KMP projects — state management, navigation, theming, performance, and platform-specific UI. | "apply compose multiplatform patterns" |
| [configure-ecc](./configure-ecc/) | Interactive installer for Everything Claude Code — guides users through selecting and installing skills and rules to user-level or project-level directories, verifies paths, and optionally optimizes installed files. | "use configure ecc" |
| [content-engine](./content-engine/) | Create platform-native content systems for X, LinkedIn, TikTok, YouTube, newsletters, and repurposed multi-platform campaigns. Use when the user wants social posts, threads, scripts, content calendars, or one source asset adapted cleanly across platforms. | "use content engine" |
| [content-hash-cache-pattern](./content-hash-cache-pattern/) | Cache expensive file processing results using SHA-256 content hashes — path-independent, auto-invalidating, with service layer separation. | "use content hash cache pattern" |
| [continuous-agent-loop](./continuous-agent-loop/) | Patterns for continuous autonomous agent loops with quality gates, evals, and recovery controls. | "use continuous agent loop" |
| [continuous-learning](./continuous-learning/) | Automatically extract reusable patterns from Claude Code sessions and save them as learned skills for future use. | "use continuous learning" |
| [continuous-learning-v2](./continuous-learning-v2/) | Instinct-based learning system that observes sessions via hooks, creates atomic instincts with confidence scoring, and evolves them into skills/commands/agents. v2.1 adds project-scoped instincts to prevent cross-project contamination. | "use continuous learning v2" |
| [cost-aware-llm-pipeline](./cost-aware-llm-pipeline/) | Cost optimization patterns for LLM API usage — model routing by task complexity, budget tracking, retry logic, and prompt caching. | "use cost aware llm pipeline" |
| [cpp-coding-standards](./cpp-coding-standards/) | C++ coding standards based on the C++ Core Guidelines (isocpp.github.io). Use when writing, reviewing, or refactoring C++ code to enforce modern, safe, and idiomatic practices. | "apply cpp coding standards" |
| [cpp-testing](./cpp-testing/) | Use only when writing/updating/fixing C++ tests, configuring GoogleTest/CTest, diagnosing failing or flaky tests, or adding coverage/sanitizers. | "run cpp testing" |
| [crosspost](./crosspost/) | Multi-platform content distribution across X, LinkedIn, Threads, and Bluesky. Adapts content per platform using content-engine patterns. Never posts identical content cross-platform. Use when the user wants to distribute content across social platforms. | "use crosspost" |
| [customs-trade-compliance](./customs-trade-compliance/) | > | "use customs trade compliance" |
| [data-scraper-agent](./data-scraper-agent/) | Build a fully automated AI-powered data collection agent for any public source — job boards, prices, news, GitHub, sports, anything. Scrapes on a schedule, enriches data with a free LLM (Gemini Flash), stores results in Notion/Sheets/Supabase, and learns from user feedback. Runs 100% free on GitHub Actions. Use when the user wants to monitor, collect, or track any public data automatically. | "use data scraper agent" |
| [database-migrations](./database-migrations/) | Database migration best practices for schema changes, data migrations, rollbacks, and zero-downtime deployments across PostgreSQL, MySQL, and common ORMs (Prisma, Drizzle, Kysely, Django, TypeORM, golang-migrate). | "use database migrations" |
| [deep-research](./deep-research/) | Multi-source deep research using firecrawl and exa MCPs. Searches the web, synthesizes findings, and delivers cited reports with source attribution. Use when the user wants thorough research on any topic with evidence and citations. | "research deep research" |
| [deployment-patterns](./deployment-patterns/) | Deployment workflows, CI/CD pipeline patterns, Docker containerization, health checks, rollback strategies, and production readiness checklists for web applications. | "apply deployment patterns" |
| [django-patterns](./django-patterns/) | Django architecture patterns, REST API design with DRF, ORM best practices, caching, signals, middleware, and production-grade Django apps. | "apply django patterns" |
| [django-security](./django-security/) | Django security best practices, authentication, authorization, CSRF protection, SQL injection prevention, XSS prevention, and secure deployment configurations. | "use django security" |
| [django-tdd](./django-tdd/) | Django testing strategies with pytest-django, TDD methodology, factory_boy, mocking, coverage, and testing Django REST Framework APIs. | "use django tdd" |
| [django-verification](./django-verification/) | Verification loop for Django projects: migrations, linting, tests with coverage, security scans, and deployment readiness checks before release or PR. | "use django verification" |
| [dmux-workflows](./dmux-workflows/) | Multi-agent orchestration using dmux (tmux pane manager for AI agents). Patterns for parallel agent workflows across Claude Code, Codex, OpenCode, and other harnesses. Use when running multiple agent sessions in parallel or coordinating multi-agent development workflows. | "use dmux workflows" |
| [docker-patterns](./docker-patterns/) | Docker and Docker Compose patterns for local development, container security, networking, volume strategies, and multi-service orchestration. | "apply docker patterns" |
| [e2e-testing](./e2e-testing/) | Playwright E2E testing patterns, Page Object Model, configuration, CI/CD integration, artifact management, and flaky test strategies. | "run e2e testing" |
| [energy-procurement](./energy-procurement/) | > | "use energy procurement" |
| [enterprise-agent-ops](./enterprise-agent-ops/) | Operate long-lived agent workloads with observability, security boundaries, and lifecycle management. | "use enterprise agent ops" |
| [eval-harness](./eval-harness/) | Formal evaluation framework for Claude Code sessions implementing eval-driven development (EDD) principles | "use eval harness" |
| [exa-search](./exa-search/) | Neural search via Exa MCP for web, code, and company research. Use when the user needs web search, code examples, company intel, people lookup, or AI-powered deep research with Exa's neural search engine. | "use exa search" |
| [fal-ai-media](./fal-ai-media/) | Unified media generation via fal.ai MCP — image, video, and audio. Covers text-to-image (Nano Banana), text/image-to-video (Seedance, Kling, Veo 3), text-to-speech (CSM-1B), and video-to-audio (ThinkSound). Use when the user wants to generate images, videos, or audio with AI. | "use fal ai media" |
| [foundation-models-on-device](./foundation-models-on-device/) | Apple FoundationModels framework for on-device LLM — text generation, guided generation with @Generable, tool calling, and snapshot streaming in iOS 26+. | "use foundation models on device" |
| [frontend-patterns](./frontend-patterns/) | Frontend development patterns for React, Next.js, state management, performance optimization, and UI best practices. | "apply frontend patterns" |
| [frontend-slides](./frontend-slides/) | Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files. Use when the user wants to build a presentation, convert a PPT/PPTX to web, or create slides for a talk/pitch. Helps non-designers discover their aesthetic through visual exploration rather than abstract choices. | "use frontend slides" |
| [golang-patterns](./golang-patterns/) | Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications. | "apply golang patterns" |
| [golang-testing](./golang-testing/) | Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Follows TDD methodology with idiomatic Go practices. | "run golang testing" |
| [inventory-demand-planning](./inventory-demand-planning/) | > | "use inventory demand planning" |
| [investor-materials](./investor-materials/) | Create and update pitch decks, one-pagers, investor memos, accelerator applications, financial models, and fundraising materials. Use when the user needs investor-facing documents, projections, use-of-funds tables, milestone plans, or materials that must stay internally consistent across multiple fundraising assets. | "use investor materials" |
| [investor-outreach](./investor-outreach/) | Draft cold emails, warm intro blurbs, follow-ups, update emails, and investor communications for fundraising. Use when the user wants outreach to angels, VCs, strategic investors, or accelerators and needs concise, personalized, investor-facing messaging. | "use investor outreach" |
| [iterative-retrieval](./iterative-retrieval/) | Pattern for progressively refining context retrieval to solve the subagent context problem | "use iterative retrieval" |
| [java-coding-standards](./java-coding-standards/) | Java coding standards for Spring Boot services: naming, immutability, Optional usage, streams, exceptions, generics, and project layout. | "apply java coding standards" |
| [jpa-patterns](./jpa-patterns/) | JPA/Hibernate patterns for entity design, relationships, query optimization, transactions, auditing, indexing, pagination, and pooling in Spring Boot. | "apply jpa patterns" |
| [kotlin-coroutines-flows](./kotlin-coroutines-flows/) | Kotlin Coroutines and Flow patterns for Android and KMP — structured concurrency, Flow operators, StateFlow, error handling, and testing. | "use kotlin coroutines flows" |
| [kotlin-exposed-patterns](./kotlin-exposed-patterns/) | JetBrains Exposed ORM patterns including DSL queries, DAO pattern, transactions, HikariCP connection pooling, Flyway migrations, and repository pattern. | "apply kotlin exposed patterns" |
| [kotlin-ktor-patterns](./kotlin-ktor-patterns/) | Ktor server patterns including routing DSL, plugins, authentication, Koin DI, kotlinx.serialization, WebSockets, and testApplication testing. | "apply kotlin ktor patterns" |
| [kotlin-patterns](./kotlin-patterns/) | Idiomatic Kotlin patterns, best practices, and conventions for building robust, efficient, and maintainable Kotlin applications with coroutines, null safety, and DSL builders. | "apply kotlin patterns" |
| [kotlin-testing](./kotlin-testing/) | Kotlin testing patterns with Kotest, MockK, coroutine testing, property-based testing, and Kover coverage. Follows TDD methodology with idiomatic Kotlin practices. | "run kotlin testing" |
| [laravel-patterns](./laravel-patterns/) | Laravel architecture patterns, routing/controllers, Eloquent ORM, service layers, queues, events, caching, and API resources for production apps. | "apply laravel patterns" |
| [laravel-plugin-discovery](./laravel-plugin-discovery/) | Discover and evaluate Laravel packages via LaraPlugins.io MCP. Use when the user wants to find plugins, check package health, or assess Laravel/PHP compatibility. | "use laravel plugin discovery" |
| [laravel-security](./laravel-security/) | Laravel security best practices for authn/authz, validation, CSRF, mass assignment, file uploads, secrets, rate limiting, and secure deployment. | "use laravel security" |
| [laravel-tdd](./laravel-tdd/) | Test-driven development for Laravel with PHPUnit and Pest, factories, database testing, fakes, and coverage targets. | "use laravel tdd" |
| [laravel-verification](./laravel-verification/) | Verification loop for Laravel projects: env checks, linting, static analysis, tests with coverage, security scans, and deployment readiness. | "use laravel verification" |
| [liquid-glass-design](./liquid-glass-design/) | iOS 26 Liquid Glass design system — dynamic glass material with blur, reflection, and interactive morphing for SwiftUI, UIKit, and WidgetKit. | "build liquid glass design" |
| [logistics-exception-management](./logistics-exception-management/) | > | "use logistics exception management" |
| [market-research](./market-research/) | Conduct market research, competitive analysis, investor due diligence, and industry intelligence with source attribution and decision-oriented summaries. Use when the user wants market sizing, competitor comparisons, fund research, technology scans, or research that informs business decisions. | "research market research" |
| [mcp-server-patterns](./mcp-server-patterns/) | Build MCP servers with Node/TypeScript SDK — tools, resources, prompts, Zod validation, stdio vs Streamable HTTP. Use Context7 or official MCP docs for latest API. | "apply mcp server patterns" |
| [nanoclaw-repl](./nanoclaw-repl/) | Operate and extend NanoClaw v2, ECC's zero-dependency session-aware REPL built on claude -p. | "use nanoclaw repl" |
| [nutrient-document-processing](./nutrient-document-processing/) | Process, convert, OCR, extract, redact, sign, and fill documents using the Nutrient DWS API. Works with PDFs, DOCX, XLSX, PPTX, HTML, and images. | "use nutrient document processing" |
| [perl-patterns](./perl-patterns/) | Modern Perl 5.36+ idioms, best practices, and conventions for building robust, maintainable Perl applications. | "apply perl patterns" |
| [perl-security](./perl-security/) | Comprehensive Perl security covering taint mode, input validation, safe process execution, DBI parameterized queries, web security (XSS/SQLi/CSRF), and perlcritic security policies. | "use perl security" |
| [perl-testing](./perl-testing/) | Perl testing patterns using Test2::V0, Test::More, prove runner, mocking, coverage with Devel::Cover, and TDD methodology. | "run perl testing" |
| [plankton-code-quality](./plankton-code-quality/) | Write-time code quality enforcement using Plankton — auto-formatting, linting, and Claude-powered fixes on every file edit via hooks. | "use plankton code quality" |
| [postgres-patterns](./postgres-patterns/) | PostgreSQL database patterns for query optimization, schema design, indexing, and security. Based on Supabase best practices. | "apply postgres patterns" |
| [production-scheduling](./production-scheduling/) | > | "use production scheduling" |
| [project-guidelines-example](./project-guidelines-example/) | Example project-specific skill template based on a real production application. | "use project guidelines example" |
| [prompt-optimizer](./prompt-optimizer/) | >- | "use prompt optimizer" |
| [python-patterns](./python-patterns/) | Pythonic idioms, PEP 8 standards, type hints, and best practices for building robust, efficient, and maintainable Python applications. | "apply python patterns" |
| [python-testing](./python-testing/) | Python testing strategies using pytest, TDD methodology, fixtures, mocking, parametrization, and coverage requirements. | "run python testing" |
| [quality-nonconformance](./quality-nonconformance/) | > | "use quality nonconformance" |
| [ralphinho-rfc-pipeline](./ralphinho-rfc-pipeline/) | RFC-driven multi-agent DAG execution pattern with quality gates, merge queues, and work unit orchestration. | "use ralphinho rfc pipeline" |
| [regex-vs-llm-structured-text](./regex-vs-llm-structured-text/) | Decision framework for choosing between regex and LLM when parsing structured text — start with regex, add LLM only for low-confidence edge cases. | "use regex vs llm structured text" |
| [returns-reverse-logistics](./returns-reverse-logistics/) | > | "use returns reverse logistics" |
| [rust-patterns](./rust-patterns/) | Idiomatic Rust patterns, ownership, error handling, traits, concurrency, and best practices for building safe, performant applications. | "apply rust patterns" |
| [rust-testing](./rust-testing/) | Rust testing patterns including unit tests, integration tests, async testing, property-based testing, mocking, and coverage. Follows TDD methodology. | "run rust testing" |
| [search-first](./search-first/) | Research-before-coding workflow. Search for existing tools, libraries, and patterns before writing custom code. Invokes the researcher agent. | "use search first" |
| [security-review](./security-review/) | Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns. | "run security review" |
| [security-scan](./security-scan/) | Scan your Claude Code configuration (.claude/ directory) for security vulnerabilities, misconfigurations, and injection risks using AgentShield. Checks CLAUDE.md, settings.json, MCP servers, hooks, and agent definitions. | "run security scan" |
| [skill-stocktake](./skill-stocktake/) | Use when auditing Claude skills and commands for quality. Supports Quick Scan (changed skills only) and Full Stocktake modes with sequential subagent batch evaluation. | "use skill stocktake" |
| [springboot-patterns](./springboot-patterns/) | Spring Boot architecture patterns, REST API design, layered services, data access, caching, async processing, and logging. Use for Java Spring Boot backend work. | "apply springboot patterns" |
| [springboot-security](./springboot-security/) | Spring Security best practices for authn/authz, validation, CSRF, secrets, headers, rate limiting, and dependency security in Java Spring Boot services. | "use springboot security" |
| [springboot-tdd](./springboot-tdd/) | Test-driven development for Spring Boot using JUnit 5, Mockito, MockMvc, Testcontainers, and JaCoCo. Use when adding features, fixing bugs, or refactoring. | "use springboot tdd" |
| [springboot-verification](./springboot-verification/) | Verification loop for Spring Boot projects: build, static analysis, tests with coverage, security scans, and diff review before release or PR. | "use springboot verification" |
| [strategic-compact](./strategic-compact/) | Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction. | "use strategic compact" |
| [swift-actor-persistence](./swift-actor-persistence/) | Thread-safe data persistence in Swift using actors — in-memory cache with file-backed storage, eliminating data races by design. | "use swift actor persistence" |
| [swift-concurrency-6-2](./swift-concurrency-6-2/) | Swift 6.2 Approachable Concurrency — single-threaded by default, @concurrent for explicit background offloading, isolated conformances for main actor types. | "use swift concurrency 6 2" |
| [swift-protocol-di-testing](./swift-protocol-di-testing/) | Protocol-based dependency injection for testable Swift code — mock file system, network, and external APIs using focused protocols and Swift Testing. | "run swift protocol di testing" |
| [swiftui-patterns](./swiftui-patterns/) | SwiftUI architecture patterns, state management with @Observable, view composition, navigation, performance optimization, and modern iOS/macOS UI best practices. | "apply swiftui patterns" |
| [tdd-workflow](./tdd-workflow/) | Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests. | "use tdd workflow" |
| [team-builder](./team-builder/) | Interactive agent picker for composing and dispatching parallel teams | "build team builder" |
| [token-budget-advisor](./token-budget-advisor/) | >- | "use token budget advisor" |
| [verification-loop](./verification-loop/) | A comprehensive verification system for Claude Code sessions. | "use verification loop" |
| [video-editing](./video-editing/) | AI-assisted video editing workflows for cutting, structuring, and augmenting real footage. Covers the full pipeline from raw capture through FFmpeg, Remotion, ElevenLabs, fal.ai, and final polish in Descript or CapCut. Use when the user wants to edit video, cut footage, create vlogs, or build video content. | "use video editing" |
| [videodb](./videodb/) | See, Understand, Act on video and audio. See- ingest from local files, URLs, RTSP/live feeds, or live record desktop; return realtime context and playable stream links. Understand- extract frames, build visual/semantic/temporal indexes, and search moments with timestamps and auto-clips. Act- transcode and normalize (codec, fps, resolution, aspect ratio), perform timeline edits (subtitles, text/image overlays, branding, audio overlays, dubbing, translation), generate media assets (image, audio, video), and create real time alerts for events from live streams or desktop capture. | "use videodb" |
| [visa-doc-translate](./visa-doc-translate/) | Translate visa application documents (images) to English and create a bilingual PDF with original and translation | "translate visa doc translate" |
| [x-api](./x-api/) | X/Twitter API integration for posting tweets, threads, reading timelines, search, and analytics. Covers OAuth auth patterns, rate limits, and platform-native content posting. Use when the user wants to interact with X programmatically. | "use x api" |

---

## OMC Built-in Skills (`omc/`)

Reference copies of skills bundled with oh-my-claudecode. Invoke these via keyword or slash command inside Claude Code:

| Skill | Description | Trigger |
|-------|-------------|---------|
| [autopilot](./omc/autopilot/) | Full autonomous idea → working code | say `"autopilot: ..."` |
| [ralph](./omc/ralph/) | Loop until task is complete and verified | say `"ralph: ..."` |
| [ultrawork](./omc/ultrawork/) | Parallel execution for large tasks | say `"ulw: ..."` |
| [ralplan](./omc/ralplan/) | Consensus planning before execution | say `"ralplan: ..."` |
| [deep-interview](./omc/deep-interview/) | Socratic requirements gathering | say `"deep interview: ..."` |
| [team](./omc/team/) | Coordinated multi-agent team | `/oh-my-claudecode:team` |
| [ultraqa](./omc/ultraqa/) | QA cycle: test, verify, fix, repeat | `/oh-my-claudecode:ultraqa` |
| [ai-slop-cleaner](./omc/ai-slop-cleaner/) | Clean up AI-generated code | say `"deslop"` |
| [ccg](./omc/ccg/) | Claude + Codex + Gemini synthesis | say `"ccg"` |
| [deep-dive](./omc/deep-dive/) | Trace investigation + requirements | `/oh-my-claudecode:deep-dive` |
| [external-context](./omc/external-context/) | Parallel external docs/web research | `/oh-my-claudecode:external-context` |
| [visual-verdict](./omc/visual-verdict/) | Screenshot visual QA verdict | `/oh-my-claudecode:visual-verdict` |
| [writer-memory](./omc/writer-memory/) | Track characters, scenes, themes | `/oh-my-claudecode:writer-memory` |
| [project-session-manager](./omc/project-session-manager/) | Worktree + tmux dev environments | `/oh-my-claudecode:project-session-manager` |
| [omc-setup](./omc/omc-setup/) | Install or refresh OMC | say `"setup omc"` |
| [mcp-setup](./omc/mcp-setup/) | Configure MCP servers | `/oh-my-claudecode:mcp-setup` |
| [configure-notifications](./omc/configure-notifications/) | Set up Telegram/Discord/Slack alerts | `/oh-my-claudecode:configure-notifications` |
| [hud](./omc/hud/) | Configure HUD display options | `/oh-my-claudecode:hud` |
| [omc-doctor](./omc/omc-doctor/) | Diagnose OMC install issues | `/oh-my-claudecode:omc-doctor` |
| [learner](./omc/learner/) | Extract a skill from a conversation | `/oh-my-claudecode:learner` |
| [sciomc](./omc/sciomc/) | Parallel scientist agents for research | say `"deep-analyze"` |
| [trace](./omc/trace/) | Evidence-driven causal tracing | `/oh-my-claudecode:trace` |

---

## Adding New Skills

Use the `skill-creator` skill:

1. Open Claude Code in any project
2. Say: *"create a skill for [your workflow]"*
3. Claude guides you through drafting, testing, and optimizing it
4. Drop the resulting folder into `~/.claude/skills/` (repo root), commit, and push

---

## Resources

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — OMC plugin (multi-agent orchestration)
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — 47 agents, 181 skills, language rules, hooks for Claude Code
- [rtk](https://github.com/rtk-ai/rtk) — Rust Token Killer: compresses Bash output before it reaches Claude, saving ~80% tokens per session (`rtk gain` to see savings)
- [claude-island](https://github.com/farouqaldori/claude-island) — macOS Dynamic Island notifications for Claude Code (permission prompts, session activity, chat history)
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
