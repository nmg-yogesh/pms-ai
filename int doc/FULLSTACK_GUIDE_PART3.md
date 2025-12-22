# Full Stack Developer Interview Guide - Part 3
## Celery, Databases, Testing, Cloud & CI/CD

---

## 4️⃣ Background Tasks – Celery

#### Q26: What is Celery and why is it needed?

**Answer:**

**Celery** is a distributed task queue for Python that handles asynchronous and scheduled tasks.

**Why Needed:**
1. **Long-running tasks** - Don't block API responses
2. **Scheduled tasks** - Cron-like periodic tasks
3. **Distributed processing** - Scale across multiple workers
4. **Retry logic** - Automatic retry on failure
5. **Task prioritization** - Different queues for different priorities

**Use Cases:**
- Sending emails
- Processing images/videos
- Generating reports
- Data synchronization
- Batch processing
- Scheduled cleanup tasks

**Basic Setup:**
```python
# celery_app.py
from celery import Celery

app = Celery(
    'tasks',
    broker='redis://localhost:6379/0',
    backend='redis://localhost:6379/0'
)

app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
)

# Task definition
@app.task(bind=True, max_retries=3)
def send_email(self, email, subject, body):
    try:
        # Send email logic
        smtp_send(email, subject, body)
        return {"status": "sent", "email": email}
    except Exception as exc:
        # Retry after 60 seconds
        raise self.retry(exc=exc, countdown=60)

@app.task
def process_image(image_path):
    # Heavy image processing
    result = resize_and_optimize(image_path)
    return result

# Periodic task
from celery.schedules import crontab

app.conf.beat_schedule = {
    'cleanup-every-night': {
        'task': 'tasks.cleanup_old_files',
        'schedule': crontab(hour=2, minute=0),
    },
}

@app.task
def cleanup_old_files():
    # Delete files older than 30 days
    delete_old_files(days=30)
```

**FastAPI Integration:**
```python
from fastapi import FastAPI, BackgroundTasks
from celery_app import send_email, process_image

app = FastAPI()

@app.post("/send-email")
async def send_email_endpoint(email: str, subject: str, body: str):
    # Queue task asynchronously
    task = send_email.delay(email, subject, body)
    
    return {
        "message": "Email queued",
        "task_id": task.id
    }

@app.get("/task/{task_id}")
async def get_task_status(task_id: str):
    task = send_email.AsyncResult(task_id)
    
    return {
        "task_id": task_id,
        "status": task.state,
        "result": task.result if task.ready() else None
    }

@app.post("/process-image")
async def process_image_endpoint(image_path: str):
    task = process_image.delay(image_path)
    return {"task_id": task.id}
```

**Running Celery:**
```bash
# Start worker
celery -A celery_app worker --loglevel=info

# Start beat scheduler (for periodic tasks)
celery -A celery_app beat --loglevel=info

# Start both
celery -A celery_app worker --beat --loglevel=info

# Multiple workers
celery -A celery_app worker --concurrency=4
```

---

#### Q27: Celery vs FastAPI BackgroundTasks?

**Answer:**

**FastAPI BackgroundTasks:**
```python
from fastapi import BackgroundTasks

def send_email_sync(email: str):
    # Runs after response is sent
    time.sleep(2)
    print(f"Email sent to {email}")

@app.post("/signup")
async def signup(email: str, background_tasks: BackgroundTasks):
    # Create user
    user = create_user(email)
    
    # Add background task
    background_tasks.add_task(send_email_sync, email)
    
    # Response sent immediately
    return {"message": "User created"}
```

**Celery:**
```python
@celery_app.task
def send_email_celery(email: str):
    time.sleep(2)
    print(f"Email sent to {email}")

@app.post("/signup")
async def signup(email: str):
    user = create_user(email)
    send_email_celery.delay(email)
    return {"message": "User created"}
```

**Comparison:**

| Feature | FastAPI BackgroundTasks | Celery |
|---------|------------------------|--------|
| **Setup** | ✅ No setup needed | ❌ Requires broker (Redis/RabbitMQ) |
| **Persistence** | ❌ Lost if server crashes | ✅ Persisted in broker |
| **Retry Logic** | ❌ No built-in retry | ✅ Automatic retry |
| **Monitoring** | ❌ No monitoring | ✅ Flower, logs |
| **Distributed** | ❌ Single server | ✅ Multiple workers |
| **Scheduling** | ❌ No scheduling | ✅ Celery Beat |
| **Priority** | ❌ No priority | ✅ Multiple queues |
| **Result Backend** | ❌ No result storage | ✅ Store results |
| **Use Case** | Simple, quick tasks | Complex, critical tasks |

**When to Use:**

**FastAPI BackgroundTasks:**
- Simple tasks (logging, notifications)
- Non-critical operations
- Small-scale applications
- Tasks that can be lost

**Celery:**
- Critical tasks (payments, orders)
- Long-running tasks
- Scheduled/periodic tasks
- Need retry logic
- Distributed processing
- Task monitoring required

**Example - Choosing the Right Tool:**
```python
# ✅ FastAPI BackgroundTasks - Simple logging
@app.post("/action")
async def action(background_tasks: BackgroundTasks):
    background_tasks.add_task(log_action, "user_action")
    return {"status": "ok"}

# ✅ Celery - Critical email with retry
@app.post("/order")
async def create_order(order: Order):
    send_order_confirmation.delay(order.id)  # Must be sent
    return {"order_id": order.id}
```

---

#### Q28: How does Celery work internally (broker, worker, backend)?

**Answer:**

**Architecture:**
```
Client (FastAPI) → Broker (Redis/RabbitMQ) → Worker → Result Backend
```

**Components:**

**1. Client (Producer):**
```python
# Sends task to broker
task = send_email.delay("user@example.com")
```

**2. Broker (Message Queue):**
- Stores tasks until workers pick them up
- Redis or RabbitMQ
- Ensures tasks aren't lost

**3. Worker (Consumer):**
- Picks tasks from broker
- Executes task function
- Stores result in backend

**4. Result Backend:**
- Stores task results
- Redis, database, or file system
- Allows checking task status

**Flow Diagram:**
```
1. Client calls: send_email.delay("user@example.com")
   ↓
2. Task serialized to JSON:
   {
     "id": "abc-123",
     "task": "send_email",
     "args": ["user@example.com"],
     "kwargs": {}
   }
   ↓
3. Sent to Broker (Redis):
   LPUSH celery "task_json"
   ↓
4. Worker polls broker:
   BRPOP celery
   ↓
5. Worker executes task:
   result = send_email("user@example.com")
   ↓
6. Result stored in backend:
   SET celery-task-meta-abc-123 '{"status": "SUCCESS", "result": ...}'
   ↓
7. Client checks result:
   task.ready()  # True
   task.result   # Return value
```

**Detailed Configuration:**
```python
from celery import Celery

app = Celery('tasks')

app.conf.update(
    # Broker settings
    broker_url='redis://localhost:6379/0',
    broker_connection_retry_on_startup=True,
    
    # Result backend
    result_backend='redis://localhost:6379/0',
    result_expires=3600,  # Results expire after 1 hour
    
    # Serialization
    task_serializer='json',
    result_serializer='json',
    accept_content=['json'],
    
    # Task execution
    task_acks_late=True,  # Acknowledge after task completes
    task_reject_on_worker_lost=True,
    worker_prefetch_multiplier=1,  # One task at a time
    
    # Routing
    task_routes={
        'tasks.send_email': {'queue': 'emails'},
        'tasks.process_image': {'queue': 'images'},
    },
)
```

---


