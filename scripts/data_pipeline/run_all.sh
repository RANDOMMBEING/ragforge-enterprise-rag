#!/bin/bash
# Data pipeline script for Enterprise RAG project
# This script downloads and generates the 95/5 noise corpus

set -e

echo "=== Enterprise RAG Data Pipeline ==="
echo ""

# Step 1: Create sample documents if they don't exist
echo "Step 1: Setting up sample documents..."

# Create true_data directory with sample concepts if they don't exist
mkdir -p seed/true_data
mkdir -p seed/noisy_data

if [ ! -s seed/true_data/concepts__configuration__configmap.html ]; then
    echo "Creating sample true_data documentation..."
    cat > seed/true_data/concepts__configuration__configmap.html << 'EOF'
<!-- Concept: Configuration ConfigMap -->
This document describes configuration ConfigMaps in Kubernetes.
ConfigMaps allow you to separate configuration artifacts from image content
to keep containerized applications portable.
EOF
fi

if [ ! -s seed/noisy_data/Inside\ IO\ Completion\ Ports.html ]; then
    echo "Creating sample noisy data..."
    cat > "seed/noisy_data/Inside IO Completion Ports.html" << 'EOF'
<!-- Noisy Data: Inside I/O Completion Ports -->
This is sample noisy data about I/O completion ports.
EOF
fi

# Step 2: Run the seed database script
echo ""
echo "Step 2: Running seed database script..."
uv run python scripts/seed_db.py seed-docs

echo ""
echo "=== Data pipeline complete ==="
