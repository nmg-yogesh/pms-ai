# ⚡ Quick Start Guide - Agentic AI System

Get up and running in 10 minutes!

## 🎯 What You'll Build

A voice-enabled AI assistant that can query your PMS database using natural language.

**Example**: Say "How many help tickets are pending?" → Get instant results with AI explanation!

---

## 📋 Prerequisites

- ✅ Python 3.9 or higher
- ✅ MySQL database (pms_dev_nmg_90)
- ✅ OpenAI API key ([Get one here](https://platform.openai.com/api-keys))
- ✅ 10 minutes of your time

---

## 🚀 Step-by-Step Setup

### Step 1: Navigate to Backend Directory (30 seconds)

```bash
cd backend
```

### Step 2: Create Virtual Environment (1 minute)

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On Linux/Mac:
source venv/bin/activate

# On Windows:
venv\Scripts\activate
```

### Step 3: Install Dependencies (2 minutes)

```bash
pip install -r requirements.txt
```

### Step 4: Configure Environment (2 minutes)

```bash
# Copy example environment file
cp .env.example .env

# Edit the .env file
nano .env  # or use your favorite editor
```

**Update these values in `.env`:**

```env
# Your database connection
DATABASE_URL=mysql+pymysql://root:your_password@localhost:3306/pms_dev_nmg_90

# Your OpenAI API key
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

### Step 5: Test Database Connection (1 minute)

```bash
python -c "from backend.models.database import test_connection; print('✅ Connected!' if test_connection() else '❌ Failed')"
```

### Step 6: Start the Server (30 seconds)

```bash
# Start FastAPI server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

### Step 7: Test the API (2 minutes)

**Open your browser and go to:**
- 📚 API Docs: http://localhost:8000/docs
- 🏥 Health Check: http://localhost:8000/api/v1/health

**Or test with cURL:**

```bash
# Health check
curl http://localhost:8000/api/v1/health

# Try a query
curl -X POST http://localhost:8000/api/v1/agentic/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "How many users are there?",
    "include_explanation": true
  }'
```

### Step 8: Run Test Script (1 minute)

```bash
# In a new terminal (keep server running)
cd backend
python test_api.py
```

---

## 🎉 Success!

If you see test results, congratulations! Your Agentic AI backend is running!

---

## 🎤 Try Voice Queries

### Option 1: Use the Interactive Docs

1. Go to http://localhost:8000/docs
2. Click on `POST /api/v1/agentic/query`
3. Click "Try it out"
4. Enter a query like: "Show me all active workflows"
5. Click "Execute"

### Option 2: Use Python Script

```python
import requests

response = requests.post(
    "http://localhost:8000/api/v1/agentic/query",
    json={
        "query": "How many help tickets are pending by all users, give names",
        "include_explanation": True
    }
)

result = response.json()
print(f"✅ Success: {result['success']}")
print(f"📊 Results: {result['result_count']} rows")
print(f"💡 Explanation: {result['explanation']}")
```

---

## 📝 Example Queries to Try

### Easy Queries (Start Here)
```
1. "Show me all users"
2. "List all departments"
3. "How many help tickets are there?"
```

### Medium Queries
```
4. "Show me pending help tickets"
5. "List users in IT department"
6. "Show me all active workflows"
```

### Advanced Queries
```
7. "How many pending tickets does each user have?"
8. "Show me high priority tickets with user names"
9. "List workflows with their current steps"
```

See [EXAMPLE_QUERIES.md](EXAMPLE_QUERIES.md) for 96+ more examples!

---

## 🐛 Troubleshooting

### Database Connection Failed

```bash
# Check if MySQL is running
mysql -u root -p

# Test connection manually
mysql -u root -p pms_dev_nmg_90
```

### OpenAI API Error

```bash
# Verify your API key
echo $OPENAI_API_KEY

# Check if key is valid at https://platform.openai.com/api-keys
```

### Import Errors

```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Make sure you're in the backend directory
pwd  # Should show .../backend
```

### Port Already in Use

```bash
# Use a different port
uvicorn main:app --reload --port 8001

# Or kill the process using port 8000
# On Linux/Mac:
lsof -ti:8000 | xargs kill -9

# On Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

---

## 📚 Next Steps

### 1. Integrate with Frontend
See [FRONTEND_INTEGRATION.md](FRONTEND_INTEGRATION.md) for React/Vue examples

### 2. Customize Prompts
Edit `backend/utils/prompts.py` to add more domain knowledge

### 3. Add Authentication
Implement JWT tokens for secure access

### 4. Deploy to Production
Follow [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

---

## 🎯 Common Use Cases

### Use Case 1: Daily Standup
**Query**: "Show me all tickets completed yesterday"

### Use Case 2: Team Performance
**Query**: "How many pending tickets does each user have?"

### Use Case 3: Workflow Monitoring
**Query**: "What's the current step in the hiring process?"

### Use Case 4: Department Analytics
**Query**: "Show me department-wise ticket count"

---

## 💡 Pro Tips

1. **Start Simple**: Begin with basic queries, then add complexity
2. **Be Specific**: Mention entity names (tickets, workflows, users)
3. **Use Filters**: Add status, dates, departments for better results
4. **Check SQL**: Review generated SQL in response to understand what's happening
5. **Iterate**: Refine your queries based on results

---

## 📞 Need Help?

- 📖 Full Documentation: [AGENTIC_AI_IMPLEMENTATION_GUIDE.md](AGENTIC_AI_IMPLEMENTATION_GUIDE.md)
- 🔍 Example Queries: [EXAMPLE_QUERIES.md](EXAMPLE_QUERIES.md)
- 🚀 Deployment: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- 🎨 Frontend: [FRONTEND_INTEGRATION.md](FRONTEND_INTEGRATION.md)

---

## ✅ Checklist

- [ ] Backend server running
- [ ] Database connected
- [ ] OpenAI API configured
- [ ] Health check passing
- [ ] Test query successful
- [ ] Ready to integrate with frontend!

**Estimated Time**: 10 minutes ⏱️

**Difficulty**: Easy 🟢

**You're all set! Happy querying! 🎉**

