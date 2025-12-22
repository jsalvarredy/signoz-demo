# Signoz OpenTelemetry Demo

> **⚠️ DEMO ENVIRONMENT** - This repository is designed for demonstration and learning purposes. It showcases a complete observability stack using Signoz and OpenTelemetry in a local Kubernetes environment.

[![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-Instrumented-blue?logo=opentelemetry)](https://opentelemetry.io/)
[![Signoz](https://img.shields.io/badge/Signoz-v0.104-orange)](https://signoz.io/)
[![Kind](https://img.shields.io/badge/Kubernetes-Kind-326CE5?logo=kubernetes)](https://kind.sigs.k8s.io/)

A complete, ready-to-run demonstration of modern observability using **Signoz** (open-source observability platform) and **OpenTelemetry** (vendor-neutral instrumentation). This demo showcases the collection and visualization of **traces**, **metrics**, and **logs** from sample applications in both **Node.js** and **Python**, demonstrating OpenTelemetry's language-agnostic capabilities.

## 🎯 What This Demo Shows

This repository demonstrates a **production-grade observability setup** that you can run locally in minutes:

- **🌐 Multi-Language Support**: See OpenTelemetry work seamlessly across Node.js and Python
- **📊 Signoz Platform**: Open-source alternative to Datadog/New Relic
- **🔍 Distributed Tracing**: Visualize request flows and identify bottlenecks
- **📈 Custom Metrics**: Track business and technical KPIs
- **📝 Structured Logging**: JSON logs with automatic trace correlation
- **🔄 Full Integration**: See how traces, metrics, and logs work together

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              Kind Kubernetes Cluster                 │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────┐         ┌──────────────┐         │
│  │    Nginx     │◄────────┤   Ingress    │         │
│  │   Ingress    │  :80    │   Resources  │         │
│  └──────┬───────┘         └──────────────┘         │
│         │                                           │
│    ┌────┴──────┬──────────────┬─────────────┐      │
│    │           │              │             │      │
│  ┌─▼────────┐ ┌▼───────────┐ ┌▼───────────┐ │      │
│  │          │ │            │ │            │ │      │
│  │ Signoz   │ │ Node.js    │ │  Python    │ │      │
│  │          │ │  Demo      │ │   Demo     │ │      │
│  │  • UI    │ │            │ │            │ │      │
│  │  • Query │◄─┤ OTEL SDK   │◄─┤ OTEL SDK   │ │      │
│  │  • OTEL  │ │  • Traces  │ │  • Traces  │ │      │
│  │  • Click │ │  • Metrics │ │  • Metrics │ │      │
│  │  House   │ │  • Logs    │ │  • Logs    │ │      │
│  │          │ │            │ │            │ │      │
│  └──────────┘ └────────────┘ └────────────┘ │      │
│                                              │      │
│        signoz.localhost    otel-example      │      │
│                            .localhost         │      │
│                                               │      │
│                              python-otel-example     │
│                              .localhost              │
└─────────────────────────────────────────────────────┘
```

## ⚡ Quick Start

### Prerequisites

Ensure you have these tools installed:

- **Docker** (≥20.10) - [Install](https://docs.docker.com/get-docker/)
- **Kind** (≥0.20) - [Install](https://kind.sigs.k8s.io/docs/user/quick-start/)
- **Kubectl** (≥1.28) - [Install](https://kubernetes.io/docs/tasks/tools/)
- **Helm** (≥3.12) - [Install](https://helm.sh/docs/intro/install/)

### One-Command Setup

```bash
./setup.sh
```

**Setup time**: ~5-10 minutes (depending on your internet connection)

The script will:
1. ✅ Validate prerequisites
2. ✅ Create a Kind cluster
3. ✅ Build and load the demo application
4. ✅ Deploy Nginx Ingress
5. ✅ Deploy Signoz (ClickHouse, OTEL Collector, Query Service, UI)
6. ✅ Deploy the instrumented demo app
7. ✅ Configure admin credentials
8. ✅ Generate sample telemetry data

### Configure DNS Resolution

Add these entries to your `/etc/hosts` file:

```bash
127.0.0.1 signoz.localhost otel-example.localhost
```

**On macOS/Linux**:
```bash
sudo sh -c 'echo "127.0.0.1 signoz.localhost otel-example.localhost python-otel-example.localhost" >> /etc/hosts'
```

**On Windows** (as Administrator):
```powershell
Add-Content C:\Windows\System32\drivers\etc\hosts "127.0.0.1 signoz.localhost otel-example.localhost python-otel-example.localhost"
```

### Access the Platform

**Signoz UI**: [http://signoz.localhost](http://signoz.localhost)
```
Email:    admin@mikroways.net
Password: Mikroways123!
```

**Demo Application**: 
- Node.js: [http://otel-example.localhost](http://otel-example.localhost)
- Python: [http://python-otel-example.localhost](http://python-otel-example.localhost)

## 🧪 Exploring the Demo

### Demo Application Endpoints

Both demo applications expose the same endpoints to showcase identical observability patterns across different programming languages:

#### Node.js Application (otel-example.localhost)

| Endpoint | Purpose | Observability Features |
|----------|---------|------------------------|
| **`/`** | Welcome page | Basic request tracing, metrics |
| **`/rolldice`** | Dice roll simulator | Custom metrics (histogram), span attributes |
| **`/work`** | Simulated work | Nested spans (DB + API), multi-operation tracing |
| **`/health`** | Health check | Simple monitoring endpoint |

#### Python Application (python-otel-example.localhost)

| Endpoint | Purpose | Observability Features |
|----------|---------|------------------------|
| **`/`** | Welcome page | Basic request tracing, metrics |
| **`/rolldice`** | Dice roll simulator | Custom metrics (histogram), span attributes |
| **`/work`** | Simulated work | Nested spans (DB + API), multi-operation tracing |
| **`/health`** | Health check | Simple monitoring endpoint |

### Generate Traffic

```bash
# Generate diverse traffic patterns to both applications
for i in {1..20}; do
  # Node.js app
  curl http://otel-example.localhost/rolldice
  curl http://otel-example.localhost/work
  
  # Python app
  curl http://python-otel-example.localhost/rolldice
  curl http://python-otel-example.localhost/work
  
  sleep 1
done
```

### What to Explore in Signoz

#### 1. **Distributed Tracing** 🔍
- Navigate to **Services** → You'll see both `otel-demo-app` (Node.js) and `otel-python-app` (Python)
- Click on either service
- Click on **Traces** to see individual requests
- Examine trace details:
  - Request duration breakdown
  - Nested spans (database queries, API calls)
  - Custom attributes (dice value, endpoints)
  - Error tracking and exceptions
- Compare traces from both languages to see identical instrumentation patterns!

#### 2. **Metrics Dashboard** 📈
- Go to **Dashboard** or **Query Builder**
- Explore metrics:
  - `http_requests_total` - Request counter by endpoint
  - `dice_roll_value` - Distribution of dice rolls
  - Auto-instrumented HTTP metrics (latency, throughput)
- Create custom visualizations and alerts

#### 3. **Structured Logs** 📝
- Navigate to **Logs**
- Filter by service: `otel-demo-app` or `otel-python-app`
- Key features:
  - JSON structured logs from both applications
  - Automatic trace correlation (trace_id, span_id)
  - Click any log to jump to its associated trace
  - Search and filter by custom attributes
- Notice how logs from different languages follow the same structured format!

#### 4. **Correlation** 🔗
- Click on any trace to see associated logs
- Switch between traces, metrics, and logs for the same request
- Understand how the **three pillars of observability** work together

## 🔧 Technical Details

### OpenTelemetry Instrumentation

The demo applications showcase production-ready instrumentation patterns in multiple languages:

#### Node.js Application (`src/otel-app/`)

| Component | Technology | Configuration |
|-----------|-----------|---------------|
| **SDK** | `@opentelemetry/sdk-node` | Centralized in `tracing.js` |
| **Traces** | OTLP/HTTP | Endpoint: `http://signoz-otel-collector:4318/v1/traces` |
| **Metrics** | OTLP/HTTP | Periodic export (10s interval) |
| **Logs** | OTLP/HTTP | Batch processor with trace correlation |
| **Auto-instrumentation** | `@opentelemetry/auto-instrumentations-node` | HTTP, Express, etc. |

#### Python Application (`src/otel-python-app/`)

| Component | Technology | Configuration |
|-----------|-----------|---------------|
| **SDK** | `opentelemetry-distro` | Configured in `app.py` |
| **Traces** | OTLP/HTTP | Endpoint: `http://signoz-otel-collector:4318/v1/traces` |
| **Metrics** | OTLP/HTTP | Periodic export (10s interval) |
| **Logs** | OTLP/HTTP | Batch processor with trace correlation |
| **Auto-instrumentation** | `opentelemetry-instrumentation-flask` | Flask auto-instrumentation |

### Custom Instrumentation Examples

```javascript
// Custom Metrics
const requestCounter = meter.createCounter('http_requests_total');
requestCounter.add(1, { endpoint: '/rolldice' });

// Custom Spans
const span = trace.getTracer('app').startSpan('operation');
span.setAttribute('custom.attribute', value);

// Structured Logs with Trace Correlation
logger.emit({
  severityText: 'INFO',
  body: JSON.stringify({ message, data }),
  attributes: {
    trace_id: spanContext.traceId,
    span_id: spanContext.spanId
  }
});
```

### Signoz Components

- **ClickHouse**: Time-series database for telemetry storage
- **OTEL Collector**: Receives, processes, and exports telemetry
- **Query Service**: API for querying telemetry data
- **Frontend**: Web UI for visualization and analysis

## 📁 Repository Structure

```
.
├── setup.sh                      # Main setup script
├── README.md                     # This file
│
├── src/
│   ├── otel-app/                 # Node.js demo application
│   │   ├── index.js              # Express app with OTEL instrumentation
│   │   ├── tracing.js            # OpenTelemetry SDK configuration
│   │   ├── package.json          # Node.js dependencies
│   │   └── Dockerfile            # Container image definition
│   │
│   └── otel-python-app/          # Python demo application
│       ├── app.py                # Flask app with OTEL instrumentation
│       ├── requirements.txt      # Python dependencies
│       └── Dockerfile            # Container image definition
│
├── charts/
│   ├── otel-demo-app/            # Helm chart for Node.js app
│   │   ├── Chart.yaml            # Chart metadata
│   │   ├── values.yaml           # Default configuration
│   │   └── templates/            # Kubernetes manifests
│   │       ├── deployment.yaml   # App deployment
│   │       ├── service.yaml      # ClusterIP service
│   │       └── ingress.yaml      # HTTP ingress
│   │
│   └── otel-python-app/          # Helm chart for Python app
│       ├── Chart.yaml            # Chart metadata
│       ├── values.yaml           # Default configuration
│       └── templates/            # Kubernetes manifests
│           ├── deployment.yaml   # App deployment
│           ├── service.yaml      # ClusterIP service
│           └── ingress.yaml      # HTTP ingress
│
└── kind/                         # Kind cluster configuration
    ├── .kind/config.yaml         # Cluster definition (port mappings)
    ├── signoz-ingress.yaml       # Signoz UI ingress
    └── helmfile.d/               # Helm chart configurations
        ├── 03-ingress-nginx.yaml # Nginx ingress controller
        ├── 04-signoz.yaml        # Signoz platform
        └── values/               # Custom values
            ├── signoz/
            │   └── values.yaml   # Signoz config (resources, ingress)
            └── ingress-nginx/
                └── values.yaml
```

## 🛠️ Customization

### Modify Demo Applications

Edit application code to add more endpoints or instrumentation:

**Node.js** (`src/otel-app/index.js`):
```javascript
// Add a new instrumented endpoint
app.get('/custom', (req, res) => {
  const span = trace.getTracer('app').startSpan('custom-operation');
  
  emitLog('INFO', 'Custom endpoint called', { user: 'demo' });
  requestCounter.add(1, { endpoint: '/custom' });
  
  // Your logic here
  
  span.end();
  res.json({ status: 'ok' });
});
```

**Python** (`src/otel-python-app/app.py`):
```python
# Add a new instrumented endpoint
@app.route('/custom')
def custom():
    with tracer.start_as_current_span('custom-operation') as span:
        emit_log('INFO', 'Custom endpoint called', user='demo')
        request_counter.add(1, {'endpoint': '/custom'})
        
        # Your logic here
        
        return jsonify({'status': 'ok'})
```

Then rebuild and redeploy:

```bash
export KUBECONFIG=$PWD/kind/.kube/config

# For Node.js app
docker build -t otel-demo-app:latest src/otel-app
kind load docker-image otel-demo-app:latest --name signoz-demo
kubectl rollout restart deployment/otel-demo-app -n demo

# For Python app
docker build -t otel-python-app:latest src/otel-python-app
kind load docker-image otel-python-app:latest --name signoz-demo
kubectl rollout restart deployment/otel-python-app -n demo
```

### Adjust Signoz Resources

Edit `kind/helmfile.d/values/signoz/values.yaml` to modify resource limits or configuration.

## 🧹 Cleanup

To completely remove the demo environment:

```bash
kind delete cluster --name signoz-demo
```

This will delete the cluster and all resources. Your Docker images will remain cached locally.

## 🐛 Troubleshooting

### Signoz UI Not Loading

**Issue**: Signoz UI shows "connection refused" or doesn't load

**Solutions**:
1. Wait 2-3 minutes after setup completes for all pods to be ready
2. Check pod status:
   ```bash
   kubectl get pods -n monitoring --kubeconfig kind/.kube/config
   ```
3. Verify all pods are `Running` (ClickHouse takes longest to start)

### No Logs/Traces Appearing

**Issue**: Signoz is empty despite generating traffic

**Solutions**:
1. Verify demo app is running:
   ```bash
   kubectl get pods -n demo --kubeconfig kind/.kube/config
   ```
2. Check app logs for errors:
   ```bash
   kubectl logs -n demo -l app.kubernetes.io/name=otel-demo-app --kubeconfig kind/.kube/config
   ```
3. Ensure OTEL collector is reachable:
   ```bash
   kubectl get svc -n monitoring --kubeconfig kind/.kube/config
   ```

### DNS Resolution Issues

**Issue**: Browser can't resolve `signoz.localhost` or `otel-example.localhost`

**Solutions**:
1. Verify `/etc/hosts` entry exists
2. Try using `127.0.0.1` directly instead of localhost
3. Clear browser DNS cache (Chrome: `chrome://net-internals/#dns`)

### Kind Cluster Issues

**Issue**: Cluster creation fails or is stuck

**Solutions**:
1. Delete existing cluster: `kind delete cluster --name signoz-demo`
2. Ensure Docker daemon is running: `docker ps`
3. Check Docker resource limits (ensure 4GB+ RAM available)

## 📚 Learning Resources

- **Signoz Documentation**: https://signoz.io/docs/
- **OpenTelemetry Docs**: https://opentelemetry.io/docs/
- **OpenTelemetry JavaScript**: https://opentelemetry.io/docs/instrumentation/js/
- **Kubernetes Kind**: https://kind.sigs.k8s.io/docs/user/quick-start/
- **ClickHouse**: https://clickhouse.com/docs/

## 🤝 Contributing

This is a demonstration repository. Feel free to fork and adapt for your own needs!

Suggestions for improvement:
- Additional language examples (Go, Java, Ruby)
- More complex microservice scenarios with service-to-service communication
- Custom Signoz dashboards and alerts
- Integration with other observability tools

## ⚖️ License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- **Signoz Team** for building an excellent open-source observability platform
- **OpenTelemetry Community** for vendor-neutral instrumentation standards
- **Kubernetes SIG** for Kind cluster tooling

---

**Built for demonstration and learning**  
Questions? Open an issue or check the troubleshooting section above.
