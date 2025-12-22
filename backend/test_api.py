"""
Simple test script for the Agentic AI API
"""
import requests
import json
from typing import Dict, Any


class AgenticAPITester:
    """Test the Agentic AI API"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.api_prefix = "/api/v1"
    
    def test_health(self) -> Dict[str, Any]:
        """Test health endpoint"""
        print("\n🔍 Testing Health Endpoint...")
        url = f"{self.base_url}{self.api_prefix}/health"
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            
            print(f"✅ Status: {data['status']}")
            print(f"✅ Database: {'Connected' if data['database_connected'] else 'Disconnected'}")
            print(f"✅ OpenAI: {'Configured' if data['openai_configured'] else 'Not Configured'}")
            
            return data
        except Exception as e:
            print(f"❌ Health check failed: {e}")
            return {}
    
    def test_query(self, query: str, include_explanation: bool = True) -> Dict[str, Any]:
        """Test query endpoint"""
        print(f"\n🔍 Testing Query: '{query}'")
        url = f"{self.base_url}{self.api_prefix}/agentic/query"
        
        payload = {
            "query": query,
            "include_explanation": include_explanation,
            "user_id": 1
        }
        
        try:
            response = requests.post(url, json=payload)
            response.raise_for_status()
            data = response.json()
            
            if data['success']:
                print(f"✅ Success!")
                print(f"📊 SQL Query: {data['sql_query']}")
                print(f"📈 Results: {data['result_count']} rows")
                print(f"⏱️  Execution Time: {data['execution_time_ms']:.2f}ms")
                
                if data['explanation']:
                    print(f"💡 Explanation: {data['explanation']}")
                
                if data['results'] and len(data['results']) > 0:
                    print(f"\n📋 Sample Results (first 3):")
                    for i, result in enumerate(data['results'][:3], 1):
                        print(f"  {i}. {result}")
            else:
                print(f"❌ Query failed: {data['error']}")
            
            return data
            
        except Exception as e:
            print(f"❌ Query test failed: {e}")
            return {}
    
    def test_examples(self) -> Dict[str, Any]:
        """Test examples endpoint"""
        print("\n🔍 Testing Examples Endpoint...")
        url = f"{self.base_url}{self.api_prefix}/agentic/examples"
        
        try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            
            print("✅ Example queries retrieved:")
            for category, queries in data.items():
                print(f"\n  📁 {category.upper()}:")
                for query in queries[:2]:  # Show first 2
                    print(f"    - {query}")
            
            return data
            
        except Exception as e:
            print(f"❌ Examples test failed: {e}")
            return {}
    
    def run_all_tests(self):
        """Run all tests"""
        print("=" * 60)
        print("🚀 Starting Agentic AI API Tests")
        print("=" * 60)
        
        # Test 1: Health check
        self.test_health()
        
        # Test 2: Get examples
        examples = self.test_examples()
        
        # Test 3: Run sample queries
        sample_queries = [
            "Show me all active workflows",
            "How many users are in each department?",
            "List all pending help tickets"
        ]
        
        for query in sample_queries:
            self.test_query(query)
        
        print("\n" + "=" * 60)
        print("✅ All tests completed!")
        print("=" * 60)


if __name__ == "__main__":
    # Create tester instance
    tester = AgenticAPITester()
    
    # Run all tests
    tester.run_all_tests()

