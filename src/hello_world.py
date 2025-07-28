#!/usr/bin/env python3
"""
Simple Flask application for CI/CD demo
"""

import os
import json
from datetime import datetime
from flask import Flask, jsonify, request

app = Flask(__name__)

# Version information
VERSION = os.getenv('APP_VERSION', '1.0.0')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.now().isoformat())

@app.route('/')
def hello_world():
    """Main endpoint returning hello message"""
    return jsonify({
        'message': 'Hello from CI/CD!',
        'version': VERSION,
        'build_date': BUILD_DATE,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/info')
def app_info():
    """Application information endpoint"""
    return jsonify({
        'name': 'devops-cicd-demo',
        'version': VERSION,
        'build_date': BUILD_DATE,
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'host': request.host,
        'user_agent': request.headers.get('User-Agent', 'Unknown')
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('FLASK_ENV') == 'development'
    
    print(f"Starting application version {VERSION} on port {port}")
    app.run(host='0.0.0.0', port=port, debug=debug) 