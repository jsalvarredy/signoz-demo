#!/bin/bash

# Simple Signoz + OpenTelemetry Demo Setup Script
# This script creates a Kind cluster and deploys:
# - Nginx Ingress Controller
# - Signoz (observability platform)
# - Demo Node.js app instrumented with OpenTelemetry

set -e  # Exit on any error

echo "🚀 Starting Signoz + OpenTelemetry Demo Setup..."

# ============================================================================
# PREREQUISITES CHECK
# ============================================================================
echo "📋 Checking prerequisites..."

command -v kind >/dev/null 2>&1 || { 
  echo "❌ kind is required but not installed. Please install from: https://kind.sigs.k8s.io/" >&2
  exit 1
}

command -v kubectl >/dev/null 2>&1 || { 
  echo "❌ kubectl is required but not installed. Please install from: https://kubernetes.io/docs/tasks/tools/" >&2
  exit 1
}

command -v helm >/dev/null 2>&1 || { 
  echo "❌ helm is required but not installed. Please install from: https://helm.sh/docs/intro/install/" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || { 
  echo "❌ docker is required but not installed. Please install from: https://docs.docker.com/get-docker/" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || { 
  echo "❌ jq is required but not installed. Please install it (e.g., sudo apt install jq)" >&2
  exit 1
}

echo "✅ All prerequisites found"

# ============================================================================
# KUBECONFIG SETUP
# ============================================================================
# Set KUBECONFIG to local directory to avoid conflicts
export KUBECONFIG="$PWD/kind/.kube/config"
mkdir -p kind/.kube

# ============================================================================
# KIND CLUSTER CREATION
# ============================================================================
if kind get clusters 2>/dev/null | grep -q "^signoz-demo$"; then
  echo "⚠️  Kind cluster 'signoz-demo' already exists. Skipping creation."
else
  echo "📦 Creating Kind cluster..."
  kind create cluster --config kind/.kind/config.yaml --name signoz-demo
  echo "✅ Kind cluster created"
fi

# ============================================================================
# BUILD AND LOAD DEMO APPLICATIONS
# ============================================================================
echo "🔨 Building OTEL demo app Docker images..."

# Build Node.js app
echo "  📦 Building Node.js app..."
docker build -t otel-demo-app:latest src/otel-app

# Build Python app
echo "  🐍 Building Python app..."
docker build -t otel-python-app:latest src/otel-python-app

# Load images into Kind cluster
echo "📤 Loading images into Kind cluster..."
kind load docker-image otel-demo-app:latest --name signoz-demo
kind load docker-image otel-python-app:latest --name signoz-demo
echo "✅ Demo app images ready"

# ============================================================================
# INSTALL CLICKHOUSE OPERATOR CRDS
# ============================================================================
# Signoz uses ClickHouse for data storage, which requires these CRDs
echo "🔧 Installing ClickHouse Operator CRDs..."
kubectl apply -f https://github.com/Altinity/clickhouse-operator/raw/0.21.2/deploy/helm/crds/CustomResourceDefinition-clickhouseinstallations.clickhouse.altinity.com.yaml
kubectl apply -f https://github.com/Altinity/clickhouse-operator/raw/0.21.2/deploy/helm/crds/CustomResourceDefinition-clickhouseinstallationtemplates.clickhouse.altinity.com.yaml
kubectl apply -f https://github.com/Altinity/clickhouse-operator/raw/0.21.2/deploy/helm/crds/CustomResourceDefinition-clickhouseoperatorconfigurations.clickhouse.altinity.com.yaml
echo "⏳ Waiting for CRDs to be established..."
sleep 5
echo "✅ CRDs installed"

# ============================================================================
# HELM REPOSITORIES
# ============================================================================
echo "📚 Adding Helm repositories..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo add signoz https://charts.signoz.io --force-update
helm repo update
echo "✅ Helm repos ready"

# ============================================================================
# INSTALL INGRESS NGINX
# ============================================================================
echo "🌐 Installing Nginx Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.hostPort.enabled=true \
  --wait \
  --timeout 5m
echo "✅ Ingress controller ready"

# ============================================================================
# INSTALL SIGNOZ
# ============================================================================
echo "📊 Installing Signoz (this may take a few minutes)..."
helm upgrade --install signoz signoz/signoz \
  --namespace monitoring \
  --create-namespace \
  --version 0.104.1 \
  -f kind/helmfile.d/values/signoz/values.yaml \
  --wait \
  --timeout 10m
echo "✅ Signoz installed"

# Apply manual Ingress for Signoz (workaround for chart configuration)
echo "🌐 Configuring Signoz Ingress..."
kubectl apply -f kind/signoz-ingress.yaml
echo "✅ Signoz is accessible via Ingress"

# ============================================================================
# INSTALL OTEL DEMO APPLICATIONS
# ============================================================================
echo "🚀 Deploying OpenTelemetry Demo Applications..."

# Deploy Node.js app
echo "  📦 Deploying Node.js app..."
helm upgrade --install otel-demo-app charts/otel-demo-app \
  --namespace demo \
  --create-namespace \
  -f charts/otel-demo-app/values.yaml \
  --wait --timeout 3m > /dev/null 2>&1

# Deploy Python app
echo "  🐍 Deploying Python app..."
helm upgrade --install otel-python-app charts/otel-python-app \
  --namespace demo \
  -f charts/otel-python-app/values.yaml \
  --wait --timeout 3m > /dev/null 2>&1

echo "✅ Demo apps deployed"

# ============================================================================
# WAIT FOR APPLICATION READINESS
# ============================================================================
echo "⏳ Waiting for demo apps to be ready..."
kubectl rollout status deployment/otel-demo-app -n demo --timeout=120s
kubectl rollout status deployment/otel-python-app -n demo --timeout=120s


# ============================================================================
# CONFIGURE SIGNOZ ADMIN USER
# ============================================================================
echo "👤 Configuring Signoz admin user..."
sleep 10  # Wait for Signoz backend to be fully ready

# Attempt to register admin user with retry logic
for i in {1..10}; do
  RESPONSE=$(curl -s -H "Host: signoz.localhost" -H "Content-Type: application/json" \
    -d '{"name":"Admin","email":"admin@mikroways.net","password":"Mikroways123!","orgName":"Mikroways"}' \
    http://localhost/api/v1/register)
  
  if echo "$RESPONSE" | grep -q "token"; then
    echo "✅ Admin user created successfully"
    break
  elif echo "$RESPONSE" | grep -q "User already exists"; then
    echo "ℹ️  Admin user already exists (OK)"
    break
  fi
  echo -n "."
  sleep 5
done
echo ""

# ============================================================================
# IMPORT PROFESSIONAL DASHBOARD
# ============================================================================
echo "📊 Importing professional dashboard..."

# Attempt to login and import dashboard with retry logic
for i in {1..5}; do
  # Get login token
  TOKEN_RESPONSE=$(curl -s -H "Host: signoz.localhost" -H "Content-Type: application/json" \
    -d '{"email":"admin@mikroways.net","password":"Mikroways123!"}' \
    http://localhost/api/v1/login)

  TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.data.accessJwt // empty')
  if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
        echo "Token Ok"
  else
        sleep 5
  fi
done
for j in {1..3}; do
    # Import dashboard
    IMPORT_RESPONSE=$(curl -s -X POST -H "Host: signoz.localhost" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d @dashboards/otel-demo-dashboard-v$j.json \
      http://localhost/api/v1/dashboards)
    
done 
echo ""

# ============================================================================
# GENERATE INITIAL TRAFFIC
# ============================================================================
echo "🚀 Generating initial telemetry traffic..."
# ============================================================================
# GENERATE SAMPLE TRAFFIC
# ============================================================================
echo "🎲 Generating sample traffic to create observability data..."
echo "   This will create traces, logs, and metrics in Signoz"

echo ""



# Function to make HTTP requests
make_request() {
    local host=$1
    local path=$2
    local method=${3:-GET}
    local data=${4:-}
    if [ "$method" = "POST" ]; then
        curl -s -X POST \
            -H "Host: $host" \
            -H "Content-Type: application/json" \
            -d "$data" \
            http://localhost${path} > /dev/null 2>&1 || true
    else
        curl -s -H "Host: $host" http://localhost${path} > /dev/null 2>&1 || true
    fi
}
# Simulate realistic e-commerce traffic                                          
for i in {1..30}; do                                                             
    # Users browsing products                                                    
    make_request "otel-example.localhost" "/api/products"                        
    make_request "otel-example.localhost" "/api/categories"                      
    # Viewing individual products                                                
    product_id=$((RANDOM % 8 + 1))                                               
    make_request "otel-example.localhost" "/api/products/${product_id}"          
    # Some users place orders (which calls Products Service from Orders Service) 
    if (( RANDOM % 3 == 0 )); then                                               
        order_data="{\"product_id\": ${product_id}, \"quantity\": 1, \"user_id\": \"user-$((RANDOM % 20 + 1))\"}"
        make_request "python-otel-example.localhost" "/api/orders" "POST" "$order_data"
    fi                                                                           
    # Health checks                                                              
    make_request "otel-example.localhost" "/health"                              
    make_request "python-otel-example.localhost" "/health"                       
    # Occasional errors for interesting data                                     
    if (( i % 10 == 0 )); then                                                   
        make_request "otel-example.localhost" "/error"                           
        make_request "python-otel-example.localhost" "/error"                    
    fi                                                                           
    # Progress indicator                                                         
    echo -n "."                                                                  
    sleep 0.3                                                                    
done   

echo "✅ Sample traffic generated"

echo "════════════════════════════════════════════════════════════════"
echo "✅ Setup Complete! Your Signoz + OpenTelemetry demo is ready"
echo "════════════════════════════════════════════════════════════════"
echo "📊 Signoz UI (Observability Platform):"
echo "   URL:      http://signoz.localhost"
echo "   User:     admin@mikroways.net"
echo "   Password: Mikroways123!"
echo ""
echo "📈 Pre-imported Dashboard:"
echo "   Go to 'Dashboards' and look for 'OpenTelemetry Demo - Professional Overview'"
echo ""
echo "🚀 Demo Application Endpoints:"

echo -e "🎮 Generate More Traffic:"                                  
echo -e "   # Browse products"                                     
echo -e "   curl http://otel-example.localhost/api/products"                     
echo ""                                                                          
echo -e "   # Create an order (triggers inter-service call)"       
echo -e "   curl -X POST http://python-otel-example.localhost/api/orders \\"     
echo -e "     -H 'Content-Type: application/json' \\"                            
echo -e "     -d '{\"product_id\": 1, \"quantity\": 1, \"user_id\": \"user-123\"}'"
echo ""                                                                          
                                                                                 
echo -e "🧹 Cleanup:"                                                
echo -e "   kind delete cluster --name signoz-demo"                        
echo ""            

echo "📝 Important Notes:"
echo "   - Add to /etc/hosts: 127.0.0.1 signoz.localhost otel-example.localhost python-otel-example.localhost"
echo "   - Generate more traffic by visiting the demo app endpoints"
echo "   - Check Signoz for:"
echo "     • Traces (see request flow and performance)"
echo "     • Metrics (http_requests_total, dice_roll_value, etc.)"
echo "     • Logs (structured JSON logs from the apps)"
echo ""
echo "🎯 What to explore in Signoz:"
echo "   1. Go to 'Services' → see both 'otel-demo-app' (Node.js) and 'otel-python-app' (Python)"
echo "   2. Go to 'Traces' → compare traces from both applications"
echo "   3. Go to 'Logs' → see structured application logs from both apps"
echo "   4. Go to 'Dashboards' → create custom visualizations"
echo "   5. Notice how OpenTelemetry works seamlessly across different languages!"
echo ""
echo "═══════════════════════════════════════════════════════════════="









# Create or update .envrc for direnv users
if [ ! -f .envrc ]; then
    cp .envrc-example .envrc 2>/dev/null || true
    if command -v direnv &> /dev/null; then
        direnv allow 2>/dev/null || true
    fi
fi
