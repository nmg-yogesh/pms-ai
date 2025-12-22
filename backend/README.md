# 🤖 PMS Agentic AI - FastAPI Backend

Natural language query interface for your PMS (Project Management System) database using AI.

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- MySQL database (pms_dev_nmg_90)
- OpenAI API key

### Installation

1. **Navigate to backend directory**
```bash
cd backend
```

2. **Create virtual environment**
```bash
python -m venv venv

# On Linux/Mac
source venv/bin/activate

# On Windows
venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
# Copy example env file
cp .env.example .env

# Edit .env with your settings
nano .env  # or use your preferred editor
```

5. **Update .env file**
```env
DATABASE_URL=mysql+pymysql://your_user:your_password@localhost:3306/pms_dev_nmg_90
OPENAI_API_KEY=sk-your-actual-openai-api-key
```

6. **Run the application**
```bash
# Development mode (with auto-reload)
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Or using Python
python main.py
```

7. **Access the API**
- API Documentation: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc
- Health Check: http://localhost:8000/api/v1/health

## 📚 API Endpoints

### Health Check
```bash
GET /api/v1/health
```

### Process Natural Language Query
```bash
POST /api/v1/agentic/query
Content-Type: application/json

{
  "query": "How many help tickets are pending by all users, give names",
  "user_id": 1,
  "include_explanation": true,
  "speak_response": false
}
```

### Get Example Queries
```bash
GET /api/v1/agentic/examples
```

### Validate SQL Query
```bash
POST /api/v1/agentic/validate-query?sql_query=SELECT * FROM users
```

## 🧪 Testing

### Test with cURL

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Query example
curl -X POST http://localhost:8000/api/v1/agentic/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "Show me all active workflows",
    "include_explanation": true
  }'
```

### Test with Python
```python
import requests

response = requests.post(
    "http://localhost:8000/api/v1/agentic/query",
    json={
        "query": "How many pending help tickets are there?",
        "include_explanation": True
    }
)

print(response.json())
```

## 📁 Project Structure

```
backend/
├── main.py                 # FastAPI application entry point
├── config.py              # Configuration settings
├── requirements.txt       # Python dependencies
├── .env.example          # Example environment variables
├── models/
│   ├── __init__.py
│   ├── database.py       # Database connection
│   └── schemas.py        # Pydantic models
├── services/
│   ├── __init__.py
│   ├── openai_service.py # OpenAI integration
│   ├── database_service.py # Database operations
│   └── agentic_service.py # Main AI logic
├── routers/
│   ├── __init__.py
│   ├── agentic.py        # AI query endpoints
│   └── health.py         # Health check endpoints
└── utils/
    ├── __init__.py
    └── prompts.py        # AI prompts
```

## 🔧 Configuration

All configuration is done via environment variables in `.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | MySQL connection string | Required |
| `OPENAI_API_KEY` | OpenAI API key | Required |
| `OPENAI_MODEL` | OpenAI model to use | gpt-4o-mini |
| `DEBUG` | Enable debug mode | True |
| `CORS_ORIGINS` | Allowed CORS origins | localhost:3000,5173,8080 |

## 📊 Supported Queries

### HIT Tickets
- "How many help tickets are pending by all users, give names"
- "Show me high priority tickets"
- "Which tickets are overdue?"
- "List all completed tickets from last week"

### FMS Workflows
- "Show me all active workflows"
- "What's the current step in the hiring process?"
- "How many purchase orders are pending?"

### Users & Departments
- "List all users in IT department"
- "Who is the team lead of Sales?"
- "Show me inactive users"

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Test database connection
mysql -u your_user -p pms_dev_nmg_90
```

### OpenAI API Issues
- Verify API key is correct
- Check API quota/billing
- Review logs for error messages

### Import Errors
```bash
# Make sure you're in the backend directory
cd backend

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

## 📝 Development

### Adding New Query Types
1. Update `utils/prompts.py` with new schema information
2. Add examples to the system prompt
3. Test with various queries

### Logging
Logs are output to console. Adjust level in `main.py`:
```python
logging.basicConfig(level=logging.DEBUG)  # More verbose
```

## 🚀 Production Deployment

1. Set `DEBUG=False` in `.env`
2. Use production-grade WSGI server
3. Set up proper logging
4. Configure firewall/security groups
5. Use environment-specific secrets

```bash
# Production run
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 📄 License

Internal use only - NMG Technologies

## 👥 Support

For issues or questions, contact the development team.

