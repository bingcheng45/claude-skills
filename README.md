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

## Installation

Clone directly into your Claude skills directory:

```bash
git clone https://github.com/bingcheng45/claude-skills.git ~/.claude/skills
```

Then restart Claude Code — skills are loaded at startup.

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
| [agent-harness-construction](./agent-harness-construction/) | Design and optimize AI agent action spaces, tool definitions, and observation formatting for higher completion rates. | |
| [agentic-engineering](./agentic-engineering/) | Operate as an agentic engineer using eval-first execution, decomposition, and cost-aware model routing. | |
| [ai-first-engineering](./ai-first-engineering/) | Engineering operating model for teams where AI agents generate a large share of implementation output. | |
| [ai-regression-testing](./ai-regression-testing/) | Regression testing strategies for AI-assisted development. Sandbox-mode API testing without database dependencies, automated bug-check workflows, and patterns to catch AI blind spots where the same model writes and reviews code. | |
| [android-clean-architecture](./android-clean-architecture/) | Clean Architecture patterns for Android and Kotlin Multiplatform projects — module structure, dependency rules, UseCases, Repositories, and data layer patterns. | |
| [api-design](./api-design/) | REST API design patterns including resource naming, status codes, pagination, filtering, error responses, versioning, and rate limiting for production APIs. | |
| [article-writing](./article-writing/) | Write articles, guides, blog posts, tutorials, newsletter issues, and other long-form content in a distinctive voice derived from supplied examples or brand guidance. Use when the user wants polished written content longer than a paragraph, especially when voice consistency, structure, and credibility matter. | |
| [autonomous-loops](./autonomous-loops/) | Patterns and architectures for autonomous Claude Code loops — from simple sequential pipelines to RFC-driven multi-agent DAG systems. | |
| [backend-patterns](./backend-patterns/) | Backend architecture patterns, API design, database optimization, and server-side best practices for Node.js, Express, and Next.js API routes. | |
| [blueprint](./blueprint/) | >- | |
| [carrier-relationship-management](./carrier-relationship-management/) | > | |
| [claude-api](./claude-api/) | Anthropic Claude API patterns for Python and TypeScript. Covers Messages API, streaming, tool use, vision, extended thinking, batches, prompt caching, and Claude Agent SDK. Use when building applications with the Claude API or Anthropic SDKs. | |
| [claude-devfleet](./claude-devfleet/) | Orchestrate multi-agent coding tasks via Claude DevFleet — plan projects, dispatch parallel agents in isolated worktrees, monitor progress, and read structured reports. | |
| [clickhouse-io](./clickhouse-io/) | ClickHouse database patterns, query optimization, analytics, and data engineering best practices for high-performance analytical workloads. | |
| [coding-standards](./coding-standards/) | Universal coding standards, best practices, and patterns for TypeScript, JavaScript, React, and Node.js development. | |
| [compose-multiplatform-patterns](./compose-multiplatform-patterns/) | Compose Multiplatform and Jetpack Compose patterns for KMP projects — state management, navigation, theming, performance, and platform-specific UI. | |
| [configure-ecc](./configure-ecc/) | Interactive installer for Everything Claude Code — guides users through selecting and installing skills and rules to user-level or project-level directories, verifies paths, and optionally optimizes installed files. | |
| [content-engine](./content-engine/) | Create platform-native content systems for X, LinkedIn, TikTok, YouTube, newsletters, and repurposed multi-platform campaigns. Use when the user wants social posts, threads, scripts, content calendars, or one source asset adapted cleanly across platforms. | |
| [content-hash-cache-pattern](./content-hash-cache-pattern/) | Cache expensive file processing results using SHA-256 content hashes — path-independent, auto-invalidating, with service layer separation. | |
| [continuous-agent-loop](./continuous-agent-loop/) | Patterns for continuous autonomous agent loops with quality gates, evals, and recovery controls. | |
| [continuous-learning](./continuous-learning/) | Automatically extract reusable patterns from Claude Code sessions and save them as learned skills for future use. | |
| [continuous-learning-v2](./continuous-learning-v2/) | Instinct-based learning system that observes sessions via hooks, creates atomic instincts with confidence scoring, and evolves them into skills/commands/agents. v2.1 adds project-scoped instincts to prevent cross-project contamination. | |
| [cost-aware-llm-pipeline](./cost-aware-llm-pipeline/) | Cost optimization patterns for LLM API usage — model routing by task complexity, budget tracking, retry logic, and prompt caching. | |
| [cpp-coding-standards](./cpp-coding-standards/) | C++ coding standards based on the C++ Core Guidelines (isocpp.github.io). Use when writing, reviewing, or refactoring C++ code to enforce modern, safe, and idiomatic practices. | |
| [cpp-testing](./cpp-testing/) | Use only when writing/updating/fixing C++ tests, configuring GoogleTest/CTest, diagnosing failing or flaky tests, or adding coverage/sanitizers. | |
| [crosspost](./crosspost/) | Multi-platform content distribution across X, LinkedIn, Threads, and Bluesky. Adapts content per platform using content-engine patterns. Never posts identical content cross-platform. Use when the user wants to distribute content across social platforms. | |
| [customs-trade-compliance](./customs-trade-compliance/) | > | |
| [data-scraper-agent](./data-scraper-agent/) | Build a fully automated AI-powered data collection agent for any public source — job boards, prices, news, GitHub, sports, anything. Scrapes on a schedule, enriches data with a free LLM (Gemini Flash), stores results in Notion/Sheets/Supabase, and learns from user feedback. Runs 100% free on GitHub Actions. Use when the user wants to monitor, collect, or track any public data automatically. | |
| [database-migrations](./database-migrations/) | Database migration best practices for schema changes, data migrations, rollbacks, and zero-downtime deployments across PostgreSQL, MySQL, and common ORMs (Prisma, Drizzle, Kysely, Django, TypeORM, golang-migrate). | |
| [deep-research](./deep-research/) | Multi-source deep research using firecrawl and exa MCPs. Searches the web, synthesizes findings, and delivers cited reports with source attribution. Use when the user wants thorough research on any topic with evidence and citations. | |
| [deployment-patterns](./deployment-patterns/) | Deployment workflows, CI/CD pipeline patterns, Docker containerization, health checks, rollback strategies, and production readiness checklists for web applications. | |
| [django-patterns](./django-patterns/) | Django architecture patterns, REST API design with DRF, ORM best practices, caching, signals, middleware, and production-grade Django apps. | |
| [django-security](./django-security/) | Django security best practices, authentication, authorization, CSRF protection, SQL injection prevention, XSS prevention, and secure deployment configurations. | |
| [django-tdd](./django-tdd/) | Django testing strategies with pytest-django, TDD methodology, factory_boy, mocking, coverage, and testing Django REST Framework APIs. | |
| [django-verification](./django-verification/) | Verification loop for Django projects: migrations, linting, tests with coverage, security scans, and deployment readiness checks before release or PR. | |
| [dmux-workflows](./dmux-workflows/) | Multi-agent orchestration using dmux (tmux pane manager for AI agents). Patterns for parallel agent workflows across Claude Code, Codex, OpenCode, and other harnesses. Use when running multiple agent sessions in parallel or coordinating multi-agent development workflows. | |
| [docker-patterns](./docker-patterns/) | Docker and Docker Compose patterns for local development, container security, networking, volume strategies, and multi-service orchestration. | |
| [e2e-testing](./e2e-testing/) | Playwright E2E testing patterns, Page Object Model, configuration, CI/CD integration, artifact management, and flaky test strategies. | |
| [energy-procurement](./energy-procurement/) | > | |
| [enterprise-agent-ops](./enterprise-agent-ops/) | Operate long-lived agent workloads with observability, security boundaries, and lifecycle management. | |
| [eval-harness](./eval-harness/) | Formal evaluation framework for Claude Code sessions implementing eval-driven development (EDD) principles | |
| [exa-search](./exa-search/) | Neural search via Exa MCP for web, code, and company research. Use when the user needs web search, code examples, company intel, people lookup, or AI-powered deep research with Exa's neural search engine. | |
| [fal-ai-media](./fal-ai-media/) | Unified media generation via fal.ai MCP — image, video, and audio. Covers text-to-image (Nano Banana), text/image-to-video (Seedance, Kling, Veo 3), text-to-speech (CSM-1B), and video-to-audio (ThinkSound). Use when the user wants to generate images, videos, or audio with AI. | |
| [foundation-models-on-device](./foundation-models-on-device/) | Apple FoundationModels framework for on-device LLM — text generation, guided generation with @Generable, tool calling, and snapshot streaming in iOS 26+. | |
| [frontend-patterns](./frontend-patterns/) | Frontend development patterns for React, Next.js, state management, performance optimization, and UI best practices. | |
| [frontend-slides](./frontend-slides/) | Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files. Use when the user wants to build a presentation, convert a PPT/PPTX to web, or create slides for a talk/pitch. Helps non-designers discover their aesthetic through visual exploration rather than abstract choices. | |
| [golang-patterns](./golang-patterns/) | Idiomatic Go patterns, best practices, and conventions for building robust, efficient, and maintainable Go applications. | |
| [golang-testing](./golang-testing/) | Go testing patterns including table-driven tests, subtests, benchmarks, fuzzing, and test coverage. Follows TDD methodology with idiomatic Go practices. | |
| [inventory-demand-planning](./inventory-demand-planning/) | > | |
| [investor-materials](./investor-materials/) | Create and update pitch decks, one-pagers, investor memos, accelerator applications, financial models, and fundraising materials. Use when the user needs investor-facing documents, projections, use-of-funds tables, milestone plans, or materials that must stay internally consistent across multiple fundraising assets. | |
| [investor-outreach](./investor-outreach/) | Draft cold emails, warm intro blurbs, follow-ups, update emails, and investor communications for fundraising. Use when the user wants outreach to angels, VCs, strategic investors, or accelerators and needs concise, personalized, investor-facing messaging. | |
| [iterative-retrieval](./iterative-retrieval/) | Pattern for progressively refining context retrieval to solve the subagent context problem | |
| [java-coding-standards](./java-coding-standards/) | Java coding standards for Spring Boot services: naming, immutability, Optional usage, streams, exceptions, generics, and project layout. | |
| [jpa-patterns](./jpa-patterns/) | JPA/Hibernate patterns for entity design, relationships, query optimization, transactions, auditing, indexing, pagination, and pooling in Spring Boot. | |
| [kotlin-coroutines-flows](./kotlin-coroutines-flows/) | Kotlin Coroutines and Flow patterns for Android and KMP — structured concurrency, Flow operators, StateFlow, error handling, and testing. | |
| [kotlin-exposed-patterns](./kotlin-exposed-patterns/) | JetBrains Exposed ORM patterns including DSL queries, DAO pattern, transactions, HikariCP connection pooling, Flyway migrations, and repository pattern. | |
| [kotlin-ktor-patterns](./kotlin-ktor-patterns/) | Ktor server patterns including routing DSL, plugins, authentication, Koin DI, kotlinx.serialization, WebSockets, and testApplication testing. | |
| [kotlin-patterns](./kotlin-patterns/) | Idiomatic Kotlin patterns, best practices, and conventions for building robust, efficient, and maintainable Kotlin applications with coroutines, null safety, and DSL builders. | |
| [kotlin-testing](./kotlin-testing/) | Kotlin testing patterns with Kotest, MockK, coroutine testing, property-based testing, and Kover coverage. Follows TDD methodology with idiomatic Kotlin practices. | |
| [laravel-patterns](./laravel-patterns/) | Laravel architecture patterns, routing/controllers, Eloquent ORM, service layers, queues, events, caching, and API resources for production apps. | |
| [laravel-plugin-discovery](./laravel-plugin-discovery/) | Discover and evaluate Laravel packages via LaraPlugins.io MCP. Use when the user wants to find plugins, check package health, or assess Laravel/PHP compatibility. | |
| [laravel-security](./laravel-security/) | Laravel security best practices for authn/authz, validation, CSRF, mass assignment, file uploads, secrets, rate limiting, and secure deployment. | |
| [laravel-tdd](./laravel-tdd/) | Test-driven development for Laravel with PHPUnit and Pest, factories, database testing, fakes, and coverage targets. | |
| [laravel-verification](./laravel-verification/) | Verification loop for Laravel projects: env checks, linting, static analysis, tests with coverage, security scans, and deployment readiness. | |
| [liquid-glass-design](./liquid-glass-design/) | iOS 26 Liquid Glass design system — dynamic glass material with blur, reflection, and interactive morphing for SwiftUI, UIKit, and WidgetKit. | |
| [logistics-exception-management](./logistics-exception-management/) | > | |
| [market-research](./market-research/) | Conduct market research, competitive analysis, investor due diligence, and industry intelligence with source attribution and decision-oriented summaries. Use when the user wants market sizing, competitor comparisons, fund research, technology scans, or research that informs business decisions. | |
| [mcp-server-patterns](./mcp-server-patterns/) | Build MCP servers with Node/TypeScript SDK — tools, resources, prompts, Zod validation, stdio vs Streamable HTTP. Use Context7 or official MCP docs for latest API. | |
| [nanoclaw-repl](./nanoclaw-repl/) | Operate and extend NanoClaw v2, ECC's zero-dependency session-aware REPL built on claude -p. | |
| [nutrient-document-processing](./nutrient-document-processing/) | Process, convert, OCR, extract, redact, sign, and fill documents using the Nutrient DWS API. Works with PDFs, DOCX, XLSX, PPTX, HTML, and images. | |
| [perl-patterns](./perl-patterns/) | Modern Perl 5.36+ idioms, best practices, and conventions for building robust, maintainable Perl applications. | |
| [perl-security](./perl-security/) | Comprehensive Perl security covering taint mode, input validation, safe process execution, DBI parameterized queries, web security (XSS/SQLi/CSRF), and perlcritic security policies. | |
| [perl-testing](./perl-testing/) | Perl testing patterns using Test2::V0, Test::More, prove runner, mocking, coverage with Devel::Cover, and TDD methodology. | |
| [plankton-code-quality](./plankton-code-quality/) | Write-time code quality enforcement using Plankton — auto-formatting, linting, and Claude-powered fixes on every file edit via hooks. | |
| [postgres-patterns](./postgres-patterns/) | PostgreSQL database patterns for query optimization, schema design, indexing, and security. Based on Supabase best practices. | |
| [production-scheduling](./production-scheduling/) | > | |
| [project-guidelines-example](./project-guidelines-example/) | Example project-specific skill template based on a real production application. | |
| [prompt-optimizer](./prompt-optimizer/) | >- | |
| [python-patterns](./python-patterns/) | Pythonic idioms, PEP 8 standards, type hints, and best practices for building robust, efficient, and maintainable Python applications. | |
| [python-testing](./python-testing/) | Python testing strategies using pytest, TDD methodology, fixtures, mocking, parametrization, and coverage requirements. | |
| [quality-nonconformance](./quality-nonconformance/) | > | |
| [ralphinho-rfc-pipeline](./ralphinho-rfc-pipeline/) | RFC-driven multi-agent DAG execution pattern with quality gates, merge queues, and work unit orchestration. | |
| [regex-vs-llm-structured-text](./regex-vs-llm-structured-text/) | Decision framework for choosing between regex and LLM when parsing structured text — start with regex, add LLM only for low-confidence edge cases. | |
| [returns-reverse-logistics](./returns-reverse-logistics/) | > | |
| [rust-patterns](./rust-patterns/) | Idiomatic Rust patterns, ownership, error handling, traits, concurrency, and best practices for building safe, performant applications. | |
| [rust-testing](./rust-testing/) | Rust testing patterns including unit tests, integration tests, async testing, property-based testing, mocking, and coverage. Follows TDD methodology. | |
| [search-first](./search-first/) | Research-before-coding workflow. Search for existing tools, libraries, and patterns before writing custom code. Invokes the researcher agent. | |
| [security-review](./security-review/) | Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns. | |
| [security-scan](./security-scan/) | Scan your Claude Code configuration (.claude/ directory) for security vulnerabilities, misconfigurations, and injection risks using AgentShield. Checks CLAUDE.md, settings.json, MCP servers, hooks, and agent definitions. | |
| [skill-stocktake](./skill-stocktake/) | Use when auditing Claude skills and commands for quality. Supports Quick Scan (changed skills only) and Full Stocktake modes with sequential subagent batch evaluation. | |
| [springboot-patterns](./springboot-patterns/) | Spring Boot architecture patterns, REST API design, layered services, data access, caching, async processing, and logging. Use for Java Spring Boot backend work. | |
| [springboot-security](./springboot-security/) | Spring Security best practices for authn/authz, validation, CSRF, secrets, headers, rate limiting, and dependency security in Java Spring Boot services. | |
| [springboot-tdd](./springboot-tdd/) | Test-driven development for Spring Boot using JUnit 5, Mockito, MockMvc, Testcontainers, and JaCoCo. Use when adding features, fixing bugs, or refactoring. | |
| [springboot-verification](./springboot-verification/) | Verification loop for Spring Boot projects: build, static analysis, tests with coverage, security scans, and diff review before release or PR. | |
| [strategic-compact](./strategic-compact/) | Suggests manual context compaction at logical intervals to preserve context through task phases rather than arbitrary auto-compaction. | |
| [swift-actor-persistence](./swift-actor-persistence/) | Thread-safe data persistence in Swift using actors — in-memory cache with file-backed storage, eliminating data races by design. | |
| [swift-concurrency-6-2](./swift-concurrency-6-2/) | Swift 6.2 Approachable Concurrency — single-threaded by default, @concurrent for explicit background offloading, isolated conformances for main actor types. | |
| [swift-protocol-di-testing](./swift-protocol-di-testing/) | Protocol-based dependency injection for testable Swift code — mock file system, network, and external APIs using focused protocols and Swift Testing. | |
| [swiftui-patterns](./swiftui-patterns/) | SwiftUI architecture patterns, state management with @Observable, view composition, navigation, performance optimization, and modern iOS/macOS UI best practices. | |
| [tdd-workflow](./tdd-workflow/) | Use this skill when writing new features, fixing bugs, or refactoring code. Enforces test-driven development with 80%+ coverage including unit, integration, and E2E tests. | |
| [team-builder](./team-builder/) | Interactive agent picker for composing and dispatching parallel teams | |
| [token-budget-advisor](./token-budget-advisor/) | >- | |
| [verification-loop](./verification-loop/) | A comprehensive verification system for Claude Code sessions. | |
| [video-editing](./video-editing/) | AI-assisted video editing workflows for cutting, structuring, and augmenting real footage. Covers the full pipeline from raw capture through FFmpeg, Remotion, ElevenLabs, fal.ai, and final polish in Descript or CapCut. Use when the user wants to edit video, cut footage, create vlogs, or build video content. | |
| [videodb](./videodb/) | See, Understand, Act on video and audio. See- ingest from local files, URLs, RTSP/live feeds, or live record desktop; return realtime context and playable stream links. Understand- extract frames, build visual/semantic/temporal indexes, and search moments with timestamps and auto-clips. Act- transcode and normalize (codec, fps, resolution, aspect ratio), perform timeline edits (subtitles, text/image overlays, branding, audio overlays, dubbing, translation), generate media assets (image, audio, video), and create real time alerts for events from live streams or desktop capture. | |
| [visa-doc-translate](./visa-doc-translate/) | Translate visa application documents (images) to English and create a bilingual PDF with original and translation | |
| [x-api](./x-api/) | X/Twitter API integration for posting tweets, threads, reading timelines, search, and analytics. Covers OAuth auth patterns, rate limits, and platform-native content posting. Use when the user wants to interact with X programmatically. | |

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

- [oh-my-claudecode](https://github.com/sgomez/oh-my-claudecode) — OMC plugin
- [Claude Code Docs](https://docs.anthropic.com/claude-code) — full documentation
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — Agent harness performance system: 30 agents, 135+ skills, 59 slash commands, hooks, and security rules for Claude Code
- [rtk](https://github.com/rtk-ai/rtk) — Rust Token Killer: compresses Bash output before it reaches Claude, saving ~80% tokens per session (`rtk gain` to see savings)
