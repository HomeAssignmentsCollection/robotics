#!/usr/bin/env python3
"""
Tests for hello_world application
"""

import pytest
import json
from datetime import datetime
from src.hello_world import app

@pytest.fixture
def client():
    """Create a test client for the Flask application"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_world_endpoint(client):
    """Test the main hello world endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'message' in data
    assert data['message'] == 'Hello from CI/CD!'
    assert 'version' in data
    assert 'build_date' in data
    assert 'timestamp' in data

def test_health_check_endpoint(client):
    """Test the health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'status' in data
    assert data['status'] == 'healthy'
    assert 'version' in data
    assert 'timestamp' in data

def test_info_endpoint(client):
    """Test the info endpoint"""
    response = client.get('/info')
    assert response.status_code == 200
    
    data = json.loads(response.data)
    assert 'name' in data
    assert data['name'] == 'devops-cicd-demo'
    assert 'version' in data
    assert 'build_date' in data
    assert 'environment' in data
    assert 'host' in data
    assert 'user_agent' in data

def test_404_endpoint(client):
    """Test non-existent endpoint"""
    response = client.get('/nonexistent')
    assert response.status_code == 404 