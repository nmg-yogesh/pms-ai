# Additional Interview Questions for Mid-Level Full Stack Developer
## Based on Real Interview Experience

---

## 🎯 System Design & Architecture

### Q1: Design a URL Shortener (like bit.ly)

**Answer:**

**Requirements:**
- Shorten long URLs
- Redirect to original URL
- Track click analytics
- Handle 1M requests/day

**Architecture:**
```
Client → Load Balancer → API Servers → Cache (Redis) → Database (PostgreSQL)
                                    ↓
                              Analytics Queue (Celery)
```

**Database Schema:**
```sql
CREATE TABLE urls (
    id BIGSERIAL PRIMARY KEY,
    short_code VARCHAR(10) UNIQUE NOT NULL,
    original_url TEXT NOT NULL,
    user_id BIGINT,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    INDEX idx_short_code (short_code)
);

CREATE TABLE clicks (
    id BIGSERIAL PRIMARY KEY,
    url_id BIGINT REFERENCES urls(id),
    clicked_at TIMESTAMP DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    country VARCHAR(2)
);
```

**Implementation:**
```python
import hashlib
import base64
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session

app = FastAPI()

def generate_short_code(url: str, length: int = 7) -> str:
    """Generate short code using hash"""
    hash_object = hashlib.md5(url.encode())
    hash_digest = hash_object.digest()
    short_code = base64.urlsafe_b64encode(hash_digest)[:length].decode()
    return short_code

@app.post("/shorten")
async def shorten_url(
    original_url: str,
    db: Session = Depends(get_db),
    redis: Redis = Depends(get_redis)
):
    # Check if URL already shortened
    existing = db.query(URL).filter(URL.original_url == original_url).first()
    if existing:
        return {"short_url": f"https://short.ly/{existing.short_code}"}
    
    # Generate unique short code
    short_code = generate_short_code(original_url)
    
    # Handle collisions
    while db.query(URL).filter(URL.short_code == short_code).first():
        short_code = generate_short_code(original_url + str(time.time()))
    
    # Save to database
    url = URL(short_code=short_code, original_url=original_url)
    db.add(url)
    db.commit()
    
    # Cache in Redis (1 hour TTL)
    await redis.setex(f"url:{short_code}", 3600, original_url)
    
    return {"short_url": f"https://short.ly/{short_code}"}

@app.get("/{short_code}")
async def redirect_url(
    short_code: str,
    db: Session = Depends(get_db),
    redis: Redis = Depends(get_redis),
    background_tasks: BackgroundTasks
):
    # Check cache first
    cached_url = await redis.get(f"url:{short_code}")
    if cached_url:
        background_tasks.add_task(track_click, short_code)
        return RedirectResponse(url=cached_url)
    
    # Query database
    url = db.query(URL).filter(URL.short_code == short_code).first()
    if not url:
        raise HTTPException(status_code=404, detail="URL not found")
    
    # Update cache
    await redis.setex(f"url:{short_code}", 3600, url.original_url)
    
    # Track click asynchronously
    background_tasks.add_task(track_click, short_code)
    
    return RedirectResponse(url=url.original_url)

def track_click(short_code: str):
    """Track click analytics"""
    # Queue to Celery for async processing
    track_click_task.delay(short_code, request.client.host, request.headers.get("user-agent"))
```

**Scaling Considerations:**
- Use Redis for caching (reduce DB load)
- Horizontal scaling with load balancer
- Database sharding by short_code hash
- CDN for static assets
- Rate limiting to prevent abuse

---

### Q2: How would you implement real-time notifications?

**Answer:**

**Options:**

**1. WebSockets (Best for real-time):**
```python
from fastapi import WebSocket, WebSocketDisconnect

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)
    
    def disconnect(self, websocket: WebSocket, user_id: int):
        self.active_connections[user_id].remove(websocket)
    
    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await manager.connect(websocket, user_id)
    try:
        while True:
            data = await websocket.receive_text()
            # Handle incoming messages
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)

# Send notification
async def notify_user(user_id: int, message: str):
    await manager.send_personal_message(message, user_id)
```

**Frontend (React):**
```typescript
function useWebSocket(userId: number) {
  const [notifications, setNotifications] = useState<Notification[]>([])
  
  useEffect(() => {
    const ws = new WebSocket(`ws://localhost:8000/ws/${userId}`)
    
    ws.onmessage = (event) => {
      const notification = JSON.parse(event.data)
      setNotifications(prev => [notification, ...prev])
    }
    
    ws.onerror = (error) => {
      console.error('WebSocket error:', error)
    }
    
    return () => ws.close()
  }, [userId])
  
  return notifications
}
```

**2. Server-Sent Events (SSE) - Simpler alternative:**
```python
from fastapi.responses import StreamingResponse
import asyncio

@app.get("/notifications/{user_id}")
async def stream_notifications(user_id: int):
    async def event_generator():
        while True:
            # Check for new notifications
            notifications = await get_user_notifications(user_id)
            if notifications:
                yield f"data: {json.dumps(notifications)}\n\n"
            await asyncio.sleep(1)
    
    return StreamingResponse(event_generator(), media_type="text/event-stream")
```

**3. Polling (Fallback):**
```typescript
function usePolling(userId: number, interval: number = 5000) {
  const [notifications, setNotifications] = useState([])
  
  useEffect(() => {
    const fetchNotifications = async () => {
      const response = await fetch(`/api/notifications/${userId}`)
      const data = await response.json()
      setNotifications(data)
    }
    
    fetchNotifications()
    const intervalId = setInterval(fetchNotifications, interval)
    
    return () => clearInterval(intervalId)
  }, [userId, interval])
  
  return notifications
}
```

**Comparison:**

| Method | Pros | Cons | Use Case |
|--------|------|------|----------|
| WebSocket | Real-time, bidirectional | Complex, connection overhead | Chat, live updates |
| SSE | Simple, auto-reconnect | One-way only | Notifications, feeds |
| Polling | Simple, works everywhere | High latency, server load | Fallback option |

---

### Q3: How do you handle file uploads in a scalable way?

**Answer:**

**Direct Upload to Cloud Storage:**

```python
from fastapi import UploadFile, File
import boto3
from botocore.exceptions import ClientError

s3_client = boto3.client('s3')

@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    try:
        # Generate unique filename
        filename = f"{uuid.uuid4()}_{file.filename}"
        
        # Upload to S3
        s3_client.upload_fileobj(
            file.file,
            'my-bucket',
            filename,
            ExtraArgs={
                'ContentType': file.content_type,
                'ACL': 'public-read'
            }
        )
        
        # Generate URL
        url = f"https://my-bucket.s3.amazonaws.com/{filename}"
        
        # Save metadata to database
        file_record = File(
            filename=filename,
            original_name=file.filename,
            url=url,
            size=file.size,
            content_type=file.content_type
        )
        db.add(file_record)
        db.commit()
        
        return {"url": url, "filename": filename}
        
    except ClientError as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Presigned URL (Better for large files):**
```python
@app.post("/upload/presigned")
async def get_presigned_url(filename: str, content_type: str):
    """Generate presigned URL for direct browser upload"""
    try:
        presigned_url = s3_client.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': 'my-bucket',
                'Key': filename,
                'ContentType': content_type
            },
            ExpiresIn=3600  # 1 hour
        )
        
        return {"upload_url": presigned_url, "file_url": f"https://my-bucket.s3.amazonaws.com/{filename}"}
    except ClientError as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Frontend (Direct Upload):**
```typescript
async function uploadFile(file: File) {
  // 1. Get presigned URL
  const response = await fetch('/upload/presigned', {
    method: 'POST',
    body: JSON.stringify({
      filename: file.name,
      content_type: file.type
    })
  })
  const { upload_url, file_url } = await response.json()
  
  // 2. Upload directly to S3
  await fetch(upload_url, {
    method: 'PUT',
    body: file,
    headers: {
      'Content-Type': file.type
    }
  })
  
  // 3. File is now available at file_url
  return file_url
}
```

**Image Processing with Celery:**
```python
@celery_app.task
def process_image(file_url: str):
    # Download image
    response = requests.get(file_url)
    img = Image.open(BytesIO(response.content))
    
    # Create thumbnails
    sizes = [(150, 150), (300, 300), (800, 800)]
    for size in sizes:
        thumbnail = img.copy()
        thumbnail.thumbnail(size)
        
        # Upload thumbnail
        buffer = BytesIO()
        thumbnail.save(buffer, format='JPEG')
        buffer.seek(0)
        
        s3_client.upload_fileobj(
            buffer,
            'my-bucket',
            f"thumbnails/{size[0]}x{size[1]}/{filename}"
        )

@app.post("/upload/image")
async def upload_image(file: UploadFile = File(...)):
    # Upload original
    url = await upload_to_s3(file)
    
    # Process asynchronously
    process_image.delay(url)
    
    return {"url": url}
```

---


