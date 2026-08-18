# Enterprise RAG Project - Setup and Running Guide

## Overview

This project is an Advanced RAG (Retrieval-Augmented Generation) system featuring:
- Text2SQL functionality
- Core RAG with caching
- LLM security and input guardrails
- Self-reflective RAG with citation evaluation
- Hybrid search (dense + sparse + reranking)
- CRAG (Constitutional RAG) support
- Rate limiting and content moderation

## Prerequisites

- Windows OS (or WSL2 on Linux/macOS)
- Python 3.12 recommended
- [uv](https://astral.sh/uv) package manager
- Docker Desktop (optional, for containerized setup)
- Upstash Redis account (for production rate limiting)
- Voyage AI API key (for reranking, optional)
- OpenAI API key
- Tavily API key (for web search)

## Installation

### Option 1: Local Development (Recommended)

```powershell
# 1. Clone the repository
git clone <repository-url>
cd EnterpriseRAG_live

# 2. Install dependencies
make install

# 3. Set up environment variables
cp .env.example .env
# Edit .env with your API keys:
# - OPENAI_API_KEY
# - TAVILY_API_KEY
# - VOYAGE_API_KEY (optional, for reranking)
# - UPSTASH_REDIS_URL and UPSTASH_REDIS_TOKEN (optional)
# - JWT_SECRET

# 4. Start the services via Docker Compose
docker-compose up -d

# This starts:
# - PostgreSQL on port 5432
# - Qdrant vector DB on port 6333
# - Redis on port 6379 (for rate limiting)

# 5. Wait for services to be ready
# Check: docker-compose ps

# 6. Run the seed script to populate databases
uv run python scripts/seed_db.py

# 7. Seed the knowledge base with documents
uv run python scripts/seed_db.py seed-docs

# 8. (Optional) Download and generate the noise corpus
make seed-data
```

### Option 2: Using Make Commands

```powershell
# First-time setup
make install          # Create venv & install all deps
make sync             # Sync deps with pyproject.toml

# Start services
make api              # Start FastAPI backend at http://localhost:8000
make streamlit        # Start Streamlit UI at http://localhost:8501

# Seed the database
make seed             # Seed DB + ingest docs into Qdrant

# Run the full workflow
make eval             # Run baseline + all + diff evaluation
```

## Running the Services

### Backend (FastAPI)

```powershell
# Start the backend server
make api

# Or manually:
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The backend will be available at `http://localhost:8000`
API docs at `http://localhost:8000/docs`

### Streamlit UI

```powershell
# Start the Streamlit interface
make streamlit

# Or manually:
uv run streamlit run scripts/streamlit_app.py
```

The Streamlit UI will be available at `http://localhost:8501`

## Docker Compose Setup

The `docker-compose.yml` includes the following services:

| Service | Port | Description |
|---------|------|-------------|
| `postgres` | 5432 | PostgreSQL database |
| `qdrant` | 6333 | Vector database |
| `redis` | 6379 | Redis for rate limiting *(recently added)* |
| `app` | 8000 | FastAPI application |

### Docker Compose Commands

```powershell
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart app
```

## Workflow Commands

### Seeding the Database

```powershell
# Seed users and basic setup
make seed

# Seed documents into Qdrant
uv run python scripts/seed_db.py seed-docs

# Full data pipeline (including noise corpus)
make seed-data
```

### Evaluation

```powershell
# Run baseline evaluation
make eval-baseline

# Run all profiles
make eval-hybrid

# Run with reranking
make eval-rerank

# Run with HYDE and CRAIG
make eval-hyde-crag

# Run all evaluations
make eval

# Generate diff between naive and all profiles
make eval-diff
```

### Testing and Quality

```powershell
make test           # Run pytest
make lint           # Run ruff check
make format         # Run ruff format
```

## Project Structure

```
e:\Projects\EnterpriseRAG_live\
├── app/                  # Main application code
│   ├── api/              # FastAPI routers
│   ├── core/           # Core logic (graph, state)
│   ├── models/         # Pydantic models
│   ├── config.py       # Settings/configuration
│   ├── middleware/     # Auth and rate limiting
│   └── security/       # Content moderation, input guards
├── scripts/              # Utility scripts
│   ├── seed_db.py      # Database seeding
│   ├── streamlit_app.py # Streamlit UI
│   └── data_pipeline/  # Data pipeline
├── services/             # RAG services
│   ├── rag_service.py  # Main RAG pipeline
│   ├── embedding_service.py
│   ├── vector_store.py
│   ├── reranking.py
│   └── ...
├── eval/                 # Evaluation scripts
├── seed/                 # Documentation seeds
├── docker-compose.yml    # Docker services
├── Dockerfile           # Docker image build
├── pyproject.toml       # Project dependencies
└── Makefile             # Build commands
```

## Configuration

### Environment Variables (.env)

Key variables in `.env`:

```dotenv
# LLM Settings
OPENAI_API_KEY=sk-...
EMBEDDING_MODEL=text-embedding-3-small
LLM_MODEL_ANSWER=gpt-4o
LLM_MODEL_GRADER=gpt-4o-mini

# Vector DB
QDRANT_URL=http://localhost:6333
QDRANT_COLLECTION=documents

# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/adv_rag

# Cache (Upstash Redis - optional)
UPSTASH_REDIS_URL=https://...
UPSTASH_REDIS_TOKEN=...

# Auth
JWT_SECRET=your-jwt-secret-key

# Rate limiting
RATE_LIMIT_REQUESTS=20
RATE_LIMIT_WINDOW_SECONDS=60

# Retrieval defaults
RERANKER_BACKEND=local          # or "voyage"
VOYAGE_API_KEY=your-voyage-key  # Get from https://voyageai.com
```

## Development Tips

### Adding New Features

1. **New API endpoint**: Add route in `app/api/` and register in `app/main.py`
2. **New service**: Add to `app/services/` and import in `app/core/graph.py`
3. **New security layer**: Add to `app/security/` and integrate in `app/api/query.py`
4. **Update config**: Modify `app/config.py` if new settings needed

### Debugging

- API docs: `http://localhost:8000/docs`
- Check `logs/` directory for application logs
- Use `make lint` to catch code style issues
- Use `make test` to run the test suite

## Troubleshooting

### Common Issues

1. **Python version mismatch**: Ensure Python 3.12 is used
   ```powershell
   python --version
   # Should show Python 3.12.x
   ```

2. **Port already in use**: Kill existing processes or change ports in config
   ```powershell
   # Find process using port 8000
   Get-NetTCPConnection -LocalPort 8000

  .kill -process (Get-Process -id (Get-NetTCPConnection -LocalPort 8000). OwningProcess -ErrorAction SilentlyContinue) -Force
   ```

3. **Database connection failed**: Verify Docker services are running
   ```powershell
   docker-compose ps
   # Should show postgres, qdrant, redis as "healthy"
   ```

4. **Redis connection errors**: If not using Docker, set Upstash credentials or run local Redis
   ```powershell
   # Start local Redis
   redis-server --daemonize yes
   ```

5. **Embedding/OpenAI errors**: Check API keys in .env file
   ```powershell
   # Verify keys are set
   cat .env | grep OPENAI_API_KEY
   ```

### Need Help?

- Check the `PROJECT_REPORT.md` for detailed project documentation
- Review `README.md` for quick start
- Run `make help` to see all available commands
<!-- final sync2 -->
