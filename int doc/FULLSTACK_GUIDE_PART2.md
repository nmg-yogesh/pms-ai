# Full Stack Developer Interview Guide - Part 2
## Python, FastAPI, Databases, Testing & More

---

## 3️⃣ Python & FastAPI (Continued)

#### Q20: How does FastAPI achieve high performance?

**Answer:**

**1. Async/Await (ASGI):**
```python
# Synchronous (blocking)
@app.get("/slow")
def slow_endpoint():
    time.sleep(1)  # Blocks entire thread
    return {"status": "done"}

# Asynchronous (non-blocking)
@app.get("/fast")
async def fast_endpoint():
    await asyncio.sleep(1)  # Doesn't block
    return {"status": "done"}
```

**2. Starlette Framework:**
- Built on Starlette (high-performance ASGI framework)
- Efficient request/response handling
- WebSocket support
- Background tasks

**3. Pydantic Validation:**
- Written in Cython (C extension)
- Fast JSON parsing
- Efficient data validation

**4. Uvicorn Server:**
```bash
# Production setup
uvicorn main:app --workers 4 --host 0.0.0.0 --port 8000

# With Gunicorn for better process management
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

**Performance Optimization Example:**
```python
from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import ORJSONResponse  # Faster than default JSON
import asyncio

app = FastAPI(default_response_class=ORJSONResponse)

# Database connection pool
from databases import Database
database = Database("postgresql://user:pass@localhost/db")

@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

# Async database query
@app.get("/users")
async def get_users():
    query = "SELECT * FROM users LIMIT 100"
    results = await database.fetch_all(query)
    return results

# Background tasks for non-critical operations
@app.post("/send-email")
async def send_email(email: str, background_tasks: BackgroundTasks):
    background_tasks.add_task(send_email_async, email)
    return {"message": "Email will be sent"}

async def send_email_async(email: str):
    await asyncio.sleep(2)  # Simulate email sending
    print(f"Email sent to {email}")
```

---

#### Q21: Explain dependency injection in FastAPI.

**Answer:**

**Dependency Injection** allows sharing logic, database connections, authentication, etc. across endpoints.

**Basic Dependency:**
```python
from fastapi import Depends, HTTPException

# Dependency function
def get_db():
    db = Database()
    try:
        yield db
    finally:
        db.close()

# Use in endpoint
@app.get("/users")
def get_users(db: Database = Depends(get_db)):
    return db.query("SELECT * FROM users")
```

**Authentication Dependency:**
```python
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
):
    token = credentials.credentials
    user = verify_token(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

@app.get("/profile")
def get_profile(current_user: User = Depends(get_current_user)):
    return current_user
```

**Nested Dependencies:**
```python
def get_db():
    db = Database()
    try:
        yield db
    finally:
        db.close()

def get_user_service(db: Database = Depends(get_db)):
    return UserService(db)

@app.get("/users/{user_id}")
def get_user(
    user_id: int,
    user_service: UserService = Depends(get_user_service)
):
    return user_service.get_by_id(user_id)
```

**Class-Based Dependencies:**
```python
class Pagination:
    def __init__(self, skip: int = 0, limit: int = 100):
        self.skip = skip
        self.limit = limit

@app.get("/items")
def get_items(pagination: Pagination = Depends()):
    return get_items_from_db(pagination.skip, pagination.limit)
```

**Dependency with Yield (Cleanup):**
```python
async def get_db_session():
    async with async_session() as session:
        yield session
        # Cleanup happens here automatically

@app.post("/users")
async def create_user(
    user: UserCreate,
    db: AsyncSession = Depends(get_db_session)
):
    db_user = User(**user.dict())
    db.add(db_user)
    await db.commit()
    return db_user
```

**Global Dependencies:**
```python
# Apply to all routes
app = FastAPI(dependencies=[Depends(verify_api_key)])

# Apply to router
router = APIRouter(dependencies=[Depends(verify_admin)])
```

---

#### Q22: How do you handle authentication & authorization in FastAPI?

**Answer:**

**JWT Authentication Implementation:**

```python
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
from pydantic import BaseModel

# Configuration
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# Models
class User(BaseModel):
    username: str
    email: str
    role: str

class TokenData(BaseModel):
    username: str
    role: str

# Password hashing
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# JWT token creation
def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Verify token
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        role: str = payload.get("role")
        
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        return TokenData(username=username, role=role)
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

# Get current user
async def get_current_user(token_data: TokenData = Depends(verify_token)):
    user = await get_user_from_db(token_data.username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# Role-based authorization
def require_role(required_role: str):
    def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role != required_role:
            raise HTTPException(
                status_code=403,
                detail=f"Requires {required_role} role"
            )
        return current_user
    return role_checker

# Login endpoint
@app.post("/login")
async def login(username: str, password: str):
    user = await authenticate_user(username, password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

# Protected endpoints
@app.get("/profile")
async def get_profile(current_user: User = Depends(get_current_user)):
    return current_user

@app.get("/admin")
async def admin_only(admin: User = Depends(require_role("admin"))):
    return {"message": "Admin access granted"}
```

**Refresh Token Implementation:**
```python
REFRESH_TOKEN_EXPIRE_DAYS = 7

def create_refresh_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@app.post("/refresh")
async def refresh_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
        
        username = payload.get("sub")
        new_access_token = create_access_token(data={"sub": username})
        
        return {"access_token": new_access_token, "token_type": "bearer"}
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid refresh token")
```

---

#### Q23: How do you structure a production-grade FastAPI project?

**Answer:**

**Project Structure:**
```
project/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app instance
│   ├── config.py               # Configuration
│   ├── dependencies.py         # Shared dependencies
│   │
│   ├── api/                    # API routes
│   │   ├── __init__.py
│   │   ├── v1/
│   │   │   ├── __init__.py
│   │   │   ├── endpoints/
│   │   │   │   ├── users.py
│   │   │   │   ├── auth.py
│   │   │   │   └── items.py
│   │   │   └── api.py          # Router aggregation
│   │   └── deps.py
│   │
│   ├── core/                   # Core functionality
│   │   ├── __init__.py
│   │   ├── security.py         # Auth, JWT
│   │   ├── config.py           # Settings
│   │   └── logging.py
│   │
│   ├── models/                 # Database models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   │
│   ├── schemas/                # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── item.py
│   │
│   ├── services/               # Business logic
│   │   ├── __init__.py
│   │   ├── user_service.py
│   │   └── item_service.py
│   │
│   ├── db/                     # Database
│   │   ├── __init__.py
│   │   ├── base.py             # Base model
│   │   ├── session.py          # DB session
│   │   └── init_db.py          # DB initialization
│   │
│   └── utils/                  # Utilities
│       ├── __init__.py
│       └── helpers.py
│
├── tests/                      # Tests
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_api/
│   └── test_services/
│
├── alembic/                    # Database migrations
│   ├── versions/
│   └── env.py
│
├── .env                        # Environment variables
├── .env.example
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
└── README.md
```

**main.py:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.api import api_router
from app.core.config import settings
from app.db.session import engine
from app.db.base import Base

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
```

**config.py:**
```python
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "My API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # Database
    DATABASE_URL: str

    # Security
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000"]

    # Redis
    REDIS_URL: str = "redis://localhost:6379"

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
```

**api/v1/endpoints/users.py:**
```python
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.schemas.user import User, UserCreate, UserUpdate
from app.services.user_service import UserService
from app.api.deps import get_db, get_current_user

router = APIRouter()

@router.get("/", response_model=List[User])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    service = UserService(db)
    return service.get_users(skip=skip, limit=limit)

@router.post("/", response_model=User)
async def create_user(
    user: UserCreate,
    db: Session = Depends(get_db)
):
    service = UserService(db)
    return service.create_user(user)

@router.get("/me", response_model=User)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    return current_user
```

**services/user_service.py:**
```python
from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash

class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_users(self, skip: int = 0, limit: int = 100):
        return self.db.query(User).offset(skip).limit(limit).all()

    def get_user_by_id(self, user_id: int):
        return self.db.query(User).filter(User.id == user_id).first()

    def create_user(self, user: UserCreate):
        hashed_password = get_password_hash(user.password)
        db_user = User(
            email=user.email,
            hashed_password=hashed_password,
            full_name=user.full_name
        )
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        return db_user
```

---

#### Q24: Difference between sync vs async endpoints in FastAPI?

**Answer:**

**Synchronous Endpoint:**
```python
@app.get("/sync")
def sync_endpoint():
    # Blocks the thread
    result = blocking_database_call()
    return result

# FastAPI runs this in a thread pool
# Good for: CPU-bound tasks, blocking I/O
```

**Asynchronous Endpoint:**
```python
@app.get("/async")
async def async_endpoint():
    # Non-blocking
    result = await async_database_call()
    return result

# Runs in the event loop
# Good for: I/O-bound tasks, async libraries
```

**When to Use Each:**

**Use `async def` when:**
- Using async libraries (aiohttp, asyncpg, motor)
- Making external API calls
- Database operations with async drivers
- WebSocket connections
- Long-running I/O operations

```python
import httpx
from databases import Database

database = Database("postgresql://...")

@app.get("/users")
async def get_users():
    # Async database query
    query = "SELECT * FROM users"
    results = await database.fetch_all(query)
    return results

@app.get("/external")
async def call_external_api():
    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/data")
        return response.json()
```

**Use `def` when:**
- Using sync libraries (requests, psycopg2, pymongo)
- CPU-intensive operations
- Simple operations without I/O

```python
import requests
from sqlalchemy.orm import Session

@app.get("/sync-external")
def call_sync_api():
    response = requests.get("https://api.example.com/data")
    return response.json()

@app.get("/users")
def get_users(db: Session = Depends(get_db)):
    return db.query(User).all()
```

**Mixing Sync and Async:**
```python
# ❌ Don't do this - blocks event loop
@app.get("/bad")
async def bad_endpoint():
    time.sleep(1)  # Blocks!
    return {"status": "done"}

# ✅ Do this instead
@app.get("/good")
async def good_endpoint():
    await asyncio.sleep(1)  # Non-blocking
    return {"status": "done"}

# ✅ Or use sync endpoint
@app.get("/also-good")
def also_good_endpoint():
    time.sleep(1)  # FastAPI runs in thread pool
    return {"status": "done"}
```

**Performance Comparison:**
```python
# Sync - handles 1 request at a time per worker
@app.get("/sync-slow")
def sync_slow():
    time.sleep(1)
    return {"done": True}

# Async - handles multiple requests concurrently
@app.get("/async-slow")
async def async_slow():
    await asyncio.sleep(1)
    return {"done": True}

# With 10 concurrent requests:
# Sync: ~10 seconds (sequential)
# Async: ~1 second (concurrent)
```

---

#### Q25: How does Pydantic help in FastAPI?

**Answer:**

**Pydantic** provides data validation, serialization, and documentation.

**1. Request Validation:**
```python
from pydantic import BaseModel, EmailStr, validator, Field
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(..., min_length=8)
    age: int = Field(..., ge=18, le=120)

    @validator('username')
    def username_alphanumeric(cls, v):
        assert v.isalnum(), 'must be alphanumeric'
        return v

    @validator('password')
    def password_strength(cls, v):
        if not any(char.isdigit() for char in v):
            raise ValueError('must contain a digit')
        if not any(char.isupper() for char in v):
            raise ValueError('must contain uppercase')
        return v

@app.post("/users")
async def create_user(user: UserCreate):
    # user is automatically validated
    # Invalid data returns 422 with detailed errors
    return user
```

**2. Response Serialization:**
```python
class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    created_at: datetime

    class Config:
        from_attributes = True  # Allows ORM models

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    # Automatically serialized to UserResponse
    # Excludes password and other fields
    return user
```

**3. Nested Models:**
```python
class Address(BaseModel):
    street: str
    city: str
    country: str

class UserWithAddress(BaseModel):
    username: str
    email: EmailStr
    address: Address

@app.post("/users")
async def create_user(user: UserWithAddress):
    # Validates nested structure
    return user

# Request body:
# {
#   "username": "john",
#   "email": "john@example.com",
#   "address": {
#     "street": "123 Main St",
#     "city": "NYC",
#     "country": "USA"
#   }
# }
```

**4. Config and Settings:**
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False

    class Config:
        env_file = ".env"
        env_file_encoding = 'utf-8'

settings = Settings()
# Automatically loads from .env file
```

**5. Custom Validators:**
```python
from pydantic import validator, root_validator

class DateRange(BaseModel):
    start_date: datetime
    end_date: datetime

    @root_validator
    def check_dates(cls, values):
        start = values.get('start_date')
        end = values.get('end_date')
        if start and end and start > end:
            raise ValueError('start_date must be before end_date')
        return values
```

---


