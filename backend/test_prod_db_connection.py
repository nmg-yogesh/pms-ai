#!/usr/bin/env python3
"""
Test script to verify production database connection
"""
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

def test_db_connection():
    """Test production database connection"""
    print("=" * 70)
    print("Testing Production Database Connection")
    print("=" * 70)
    
    # Import config
    try:
        from backend.config import settings
        print("✓ Config loaded successfully")
        print(f"  Environment: {settings.ENVIRONMENT}")
        print(f"  Debug: {settings.DEBUG}")
    except Exception as e:
        print(f"✗ Failed to load config: {e}")
        return False
    
    # Show database info (masked)
    db_url = settings.DATABASE_URL
    if '@' in db_url:
        # Extract parts
        parts = db_url.split('@')
        host_db = parts[1] if len(parts) > 1 else 'unknown'
        user_part = parts[0].split('://')[-1].split(':')[0] if len(parts) > 0 else 'unknown'
        
        print(f"\n  Database User: {user_part}")
        print(f"  Database Host: {host_db}")
    
    # Test database connection
    print("\n" + "=" * 70)
    print("Testing Database Connection")
    print("=" * 70)
    
    try:
        from sqlalchemy import create_engine, text
        
        # Create engine
        engine = create_engine(
            settings.DATABASE_URL,
            pool_pre_ping=True,
            pool_size=5,
            max_overflow=10
        )
        
        print("✓ Database engine created")
        
        # Test connection
        with engine.connect() as conn:
            print("✓ Database connection established")
            
            # Get database name
            result = conn.execute(text("SELECT DATABASE()"))
            db_name = result.scalar()
            print(f"✓ Connected to database: {db_name}")
            
            # Get table count
            result = conn.execute(text("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = DATABASE()
            """))
            table_count = result.scalar()
            print(f"✓ Found {table_count} tables in database")
            
            # List some tables
            result = conn.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = DATABASE()
                ORDER BY table_name
                LIMIT 10
            """))
            tables = [row[0] for row in result]
            
            print(f"\n  Sample tables (first 10):")
            for table in tables:
                print(f"    - {table}")
            
            # Get total row count estimate
            result = conn.execute(text("""
                SELECT SUM(table_rows) as total_rows
                FROM information_schema.tables 
                WHERE table_schema = DATABASE()
            """))
            total_rows = result.scalar() or 0
            print(f"\n  Estimated total rows: {total_rows:,}")
            
        print("\n" + "=" * 70)
        print("✓ DATABASE CONNECTION TEST PASSED!")
        print("=" * 70)
        return True
        
    except Exception as e:
        print(f"\n✗ Database connection failed: {e}")
        import traceback
        traceback.print_exc()
        print("\n" + "=" * 70)
        print("✗ DATABASE CONNECTION TEST FAILED!")
        print("=" * 70)
        return False


if __name__ == "__main__":
    success = test_db_connection()
    sys.exit(0 if success else 1)

