#!/usr/bin/env python3
"""
Hello World Flask Application
A simple microservice for DevOps CI/CD demonstration
"""

import os
import datetime
from flask import Flask, jsonify

app = Flask(__name__)

# Get version and build info from environment variables
APP_VERSION = os.getenv('APP_VERSION', '1.0.2')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.datetime.now().isoformat())
VCS_REF = os.getenv('VCS_REF', 'latest')

@app.route('/')
def hello_world():
    """Main endpoint returning hello message"""
    return {
        'message': 'Hello from CI/CD!',
        'version': APP_VERSION,
        'build_date': BUILD_DATE,
        'vcs_ref': VCS_REF,
        'status': 'running',
        'deployment': 'v1.0.2 - New Feature Added! 🚀'
    }

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return {
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'version': APP_VERSION,
        'service': 'devops-cicd-demo'
    }

@app.route('/info')
def info():
    """Application information endpoint"""
    return {
        'application': 'devops-cicd-demo',
        'version': APP_VERSION,
        'build_date': BUILD_DATE,
        'vcs_ref': VCS_REF,
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'region': os.getenv('AWS_REGION', 'eu-north-1'),
        'features': [
            'Flask microservice',
            'Docker containerization',
            'AWS ECS deployment',
            'CI/CD pipeline',
            'Health monitoring',
            'Version management'
        ]
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False) 