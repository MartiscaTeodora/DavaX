# DavaX Academy

This repository is a learning portfolio built during the DavaX Academy program. It collects notes, exercises, database assignments, Python examples, prompt engineering work, and full-stack AI applications.

The main learning path moves from AI fundamentals and prompt design into databases, ETL, Python, APIs, LLM integration, RAG, and full-stack product development.

## What Was Learned

### Module 1 - Generative AI, Prompt Engineering, and Custom GPTs

This module focused on how to communicate with AI systems in a structured, reliable way.

Topics covered:

- prompt engineering fundamentals
- clear instructions, context, constraints, delimiters, and output formats
- role prompting, zero-shot prompting, few-shot prompting, and tool-use patterns
- advanced prompt structures for software engineering, AI engineering, data science, and career coaching
- custom GPT design, including behavior rules, tone, memory expectations, source requirements, and anti-hallucination constraints
- GenAI business-case thinking through a value-calculator GPT concept
- feasibility analysis for AI solutions: RAG, fine-tuning, tool use, classical ML, or no-AI approaches
- ROI reasoning, KPI definition, risk analysis, and privacy/governance considerations

Main artifacts:

- `Module 1/Prompt egineering/Prompt_Engineering___exercise__.docx`
- `Module 1/Prompt egineering/_Advanced_Prompt_Engineering_Full_Prompts_examples.docx`
- `Module 1/Customs GPT/Custom_GPTs___exercise.docx`

### Module 2 - SQL, Relational Databases, PL/SQL, and ETL

This module focused on database design, querying, procedural SQL, and data integration.

Topics covered:

- RDBMS fundamentals: tables, columns, data types, primary keys, foreign keys, constraints, schemas, and relationships
- SQL DDL and DML: `CREATE`, `ALTER`, `INSERT`, `SELECT`, `UPDATE`, `DROP`
- database normalization and relationship modeling
- indexes, views, schema-bound views, and reporting queries
- SQL joins and investigative querying through the SQL Murder Mystery exercises
- analytic/window functions such as `SUM(...) OVER (PARTITION BY ...)`
- JSON validation in SQL Server with `ISJSON`
- Oracle PL/SQL packages, procedures, cursors, exception handling, and autonomous transactions
- reusable debugging/logging framework with a `DEBUG_LOG` table
- ETL concepts: extract, transform, load, staging tables, dimensions, fact tables, mapping, data cleansing, and reporting
- building a mini data warehouse for employee daily activity

Main projects and assignments:

- `Module 2/1. generic RDBMS/tema.sql` - Timesheet database with employees, clients, locations, projects, timesheets, entries, constraints, indexes, and reporting views.
- `murder mystery/` - SQL investigation exercises using multi-table queries.
- `Module 2/2. PL SQL/ex cu comentarii.sql` - PL/SQL debugging package and salary adjustment procedure.
- `Module 2/3. ETL/assignment_timesheet_etl.sql` - ETL pipeline that loads timesheets, absences, leave, and training into a reporting fact table.

### Module 3 - Python, Git, APIs, LLM Integration, RAG, and Full-Stack AI Apps

This module connected programming fundamentals with real AI-backed applications.

Topics covered:

- Git fundamentals: repository initialization, cloning, staging, committing, pushing, pulling, branching, merging, cherry-picking, reverting, resetting, tagging, and stashing
- Git configuration and basic GitHub/Copilot usage
- Python basics: variables, printing, lists, arrays, built-in functions, and async programming with `asyncio`
- Python OOP: classes, objects, inheritance, encapsulation, polymorphism, static methods, class methods, properties, and dunder methods
- API fundamentals: HTTP methods, headers, authentication, request bodies, query parameters, responses, and status-oriented thinking
- OpenAI API and LLM application patterns
- embeddings and semantic search
- RAG pipelines with ChromaDB
- tool calling/function calling
- text-to-speech and speech-to-text
- FastAPI backend development
- React/Vite frontend development
- testing backend and frontend behavior
- full-stack architecture with persistence, external APIs, and deployment files

Main artifacts:

- `Module 3/python/ex.py` - Python basics and async examples.
- `Module 3/python/oop python.py` - Object-oriented programming examples.
- `Module 3/git/comenzi git notite.txt` - Git command notes.
- `Module 3/llm integration/` - API and OpenAI integration notes.
- `Module 3/tema/` - Smart Librarian AI assistant.
- `ai-car-assistant/` - Full-stack AI trip planning assistant.

## Featured Projects

### Smart Librarian - RAG Book Recommendation Assistant

Location: `Module 3/tema/`

Smart Librarian is an AI chatbot that recommends books based on natural-language user interests. It uses a local JSON book database, OpenAI embeddings, ChromaDB semantic retrieval, and LLM-generated recommendations.

What it demonstrates:

- local knowledge-base design with `books.json`
- embedding generation
- vector storage with ChromaDB
- semantic retrieval based on user intent
- prompt construction using retrieved context
- tool calling through `get_summary_by_title(title)`
- CLI interaction
- FastAPI API endpoints
- React/Vite UI
- input moderation
- optional speech-to-text and text-to-speech
- fallback behavior for API/network failures

Useful files:

- `Module 3/tema/app.py`
- `Module 3/tema/api.py`
- `Module 3/tema/rag_utils.py`
- `Module 3/tema/data_utils.py`
- `Module 3/tema/audio_utils.py`
- `Module 3/tema/smart-librarian-ui/`

See also: `Module 3/tema/README.md`

### AI Car Assistant - Full-Stack AI Trip Planning Application

Location: `ai-car-assistant/`

AI Car Assistant is a full-stack trip planning prototype for drivers. It takes a trip request, driver preferences, vehicle state, route constraints, and external data, then recommends route options with cost, time, charging/refueling stops, service warnings, and an explanation.

What it demonstrates:

- FastAPI backend architecture
- React/Vite frontend
- PostgreSQL persistence with SQLAlchemy models
- authentication, user profile, preferences, trip history, and feedback
- route alternatives from Google Routes API
- scenic scoring using Google Places
- charging and refueling recommendations using OpenChargeMap and local fallback data
- vehicle state normalization and snapshot building
- EV and ICE support
- route scoring based on time, cost, scenic value, constraints, and previous feedback
- service-risk alerts based on mileage and last service
- optional OpenAI explanation layer with deterministic rule-based fallback
- backend tests with `pytest`
- frontend tests with `vitest`
- Docker, docker-compose, and Kubernetes deployment files

Useful files:

- `ai-car-assistant/src/api/main.py`
- `ai-car-assistant/src/services/recommendation_service.py`
- `ai-car-assistant/src/services/constraints_service.py`
- `ai-car-assistant/src/services/explanation_service.py`
- `ai-car-assistant/src/models/schemas.py`
- `ai-car-assistant/src/models/db_models.py`
- `ai-car-assistant/frontend/`
- `ai-car-assistant/tests/`
- `ai-car-assistant/k8s/`

See also: `ai-car-assistant/README.md`

### Timesheet Database and ETL Data Warehouse

Location: `Module 2/`

The database assignments build a realistic employee activity reporting flow. The work starts with an operational timesheet schema and expands into an ETL process that combines work entries, absences, leave, training attendance, and missing hours into a single fact table.

What it demonstrates:

- relational modeling
- operational schemas and reporting schemas
- lookup/reference tables
- staging tables
- fact table design
- data validation with constraints
- indexes for lookup and reporting performance
- transformation from raw inputs into report-ready records
- daily and monthly activity reports

Core output:

- `dw.Fact_EmployeeActivity`

### PL/SQL Debugging Framework

Location: `Module 2/2. PL SQL/`

The PL/SQL assignment implements a reusable debugging package and applies it inside a salary adjustment procedure.

What it demonstrates:

- package specification and body
- debug mode toggling
- message logging
- variable logging
- autonomous transaction error logging
- explicit cursors
- exception handling
- repeatable script setup and cleanup

Core objects:

- `debug_log`
- `debug_utils`
- `adjust_salaries_by_commission`

## Technology Stack

Languages and databases:

- SQL Server / T-SQL
- Oracle PL/SQL
- Python
- JavaScript
- JSON

Backend and AI:

- FastAPI
- OpenAI API
- ChromaDB
- SQLAlchemy
- Pydantic
- PostgreSQL
- requests/http concepts

Frontend:

- React
- Vite
- CSS
- Vitest

Engineering and deployment:

- Git
- GitHub concepts
- pytest
- Docker
- docker-compose
- Kubernetes manifests

## Repository Map

```text
.
|-- Module 1/
|   |-- Prompt egineering/
|   `-- Customs GPT/
|-- Module 2/
|   |-- 1. generic RDBMS/
|   |-- 2. PL SQL/
|   `-- 3. ETL/
|-- Module 3/
|   |-- python/
|   |-- git/
|   |-- llm integration/
|   `-- tema/
|-- ai-car-assistant/
|-- murder mystery/
|-- chroma_db/
`-- README.md
```

## How To Explore

Start with the root modules in order if you want to follow the learning path:

1. `Module 1/` - AI prompting and custom GPT thinking.
2. `Module 2/` - SQL, PL/SQL, and ETL foundations.
3. `Module 3/` - Python, APIs, LLM integration, and AI applications.
4. `Module 3/tema/` - Smart Librarian RAG project.
5. `ai-car-assistant/` - Full-stack AI trip planning project.

For runnable instructions, use the project-specific READMEs:

- `Module 3/tema/README.md`
- `ai-car-assistant/README.md`

## Learning Outcome

By the end of this work, the repository shows a progression from asking better AI questions to building AI-powered software systems. The key outcome is the ability to connect business problems, data models, backend logic, frontend interfaces, and LLM capabilities into practical applications.
