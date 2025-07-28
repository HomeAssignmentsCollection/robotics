# =============================================================================
# DOCKERFILE BEST PRACTICES CHECKLIST
# =============================================================================
# ✅ Multi-stage build: Reduces final image size
# ✅ Base image: Using specific version (3.11-slim) for security and size
# ✅ Non-root user: Running as appuser for security
# ✅ Layer optimization: Combining RUN commands, cleaning cache
# ✅ Environment variables: Set at build time for optimization
# ✅ Health check: Application health monitoring
# ✅ Security: Minimal base image, no unnecessary packages
# ✅ Dependencies: Copy requirements first for better caching
# ✅ Working directory: Explicit WORKDIR setting
# ✅ Port exposure: Explicit EXPOSE directive
# ✅ CMD vs ENTRYPOINT: Using CMD for flexibility
# ✅ Virtual environment: Isolated Python environment
# ✅ Cache optimization: Using --no-cache-dir for pip
# ✅ File ownership: Proper file permissions
# ✅ Resource limits: Gunicorn worker configuration
# ✅ Logging: Unbuffered Python output
# ✅ Cleanup: Removing apt cache and temporary files
# ✅ Version support: Build arguments for versioning
# =============================================================================

# Multi-stage build for Python Flask application
FROM python:3.11-slim as builder

# Build arguments for versioning
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

# Set environment variables for build optimization
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies in a single layer
RUN apt-get update && apt-get install -y \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# =============================================================================
# PRODUCTION STAGE
# =============================================================================

# Production stage with minimal base image
FROM python:3.11-slim

# Build arguments for versioning (must be redeclared in each stage)
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

# Set environment variables for production
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app" \
    APP_VERSION=$APP_VERSION \
    BUILD_DATE=$BUILD_DATE \
    VCS_REF=$VCS_REF

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder stage
COPY --from=builder /opt/venv /opt/venv

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=appuser:appuser src/ ./src/

# Create necessary directories with proper ownership
RUN mkdir -p /app/logs && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 5000

# Add version labels
LABEL maintainer="devops@example.com" \
      version="$APP_VERSION" \
      build-date="$BUILD_DATE" \
      vcs-ref="$VCS_REF" \
      description="DevOps CI/CD Demo Application" \
      org.opencontainers.image.version="$APP_VERSION" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.title="DevOps CI/CD Demo" \
      org.opencontainers.image.description="A comprehensive DevOps CI/CD pipeline demonstration"

# Health check with proper intervals
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run the application with production settings
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--timeout", "120", \
     "--max-requests", "1000", \
     "--max-requests-jitter", "100", \
     "--keep-alive", "2", \
     "--log-level", "info", \
     "src.hello_world:app"] 