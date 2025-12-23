# Dashboard Setup Guide for Signoz Demo

> [!NOTE]
> **Automated Installation**: This dashboard is now automatically imported when you run `./setup.sh`. 
> You can find it in the **Dashboards** section of Signoz as "OpenTelemetry Demo - Professional Overview".
> 
> The instructions below remain available for reference, manual backup, or customization purposes.

> **🎯 Purpose**: This guide will help you create or customize a comprehensive, professional dashboard that showcases the full power of Signoz's observability platform with your demo applications.

## 📊 Dashboard Overview

This dashboard demonstrates:
- **Multi-language observability** across Node.js and Python applications
- **Real-time performance metrics** (request rates, latencies, throughput)
- **Distributed tracing** with service dependencies
- **Structured logging** with automatic trace correlation
- **Custom business metrics** (dice rolls, endpoint analytics)
- **Error tracking** and health monitoring

**Estimated setup time**: 15-20 minutes

---

## 🚀 Quick Start

### Step 1: Access Signoz

1. Open your browser and navigate to [http://signoz.localhost](http://signoz.localhost)
2. Login with credentials:
   - Email: `admin@mikroways.net`
   - Password: `Mikroways123!`

### Step 2: Generate Sample Data

Before creating the dashboard, generate some traffic to populate metrics:

```bash
# Run this in your terminal to generate diverse traffic patterns
for i in {1..50}; do
  curl -s http://otel-example.localhost/ > /dev/null
  curl -s http://otel-example.localhost/rolldice > /dev/null
  curl -s http://otel-example.localhost/work > /dev/null
  curl -s http://otel-example.localhost/error > /dev/null
  curl -s http://python-otel-example.localhost/ > /dev/null
  curl -s http://python-otel-example.localhost/rolldice > /dev/null
  curl -s http://python-otel-example.localhost/work > /dev/null
  curl -s http://python-otel-example.localhost/error > /dev/null
  sleep 0.5
done
```

### Step 3: Create the Dashboard

1. From the Signoz sidebar, click **"Dashboards"**
2. Click **"New Dashboard"** button
3. Click the **"Edit"** button (top right)
4. Enter the following details:
   - **Name**: `OpenTelemetry Demo - Professional Overview`
   - **Description**: `Comprehensive observability dashboard showcasing multi-language instrumentation, distributed tracing, metrics, and logs`
   - **Tags**: Add tags like `demo`, `opentelemetry`, `production-ready`
5. Click **"Save"**

Now you're ready to add panels!

---

## 📈 Dashboard Panels

Follow the sections below to add each panel. For each panel:
1. Click **"New Panel"** button
2. Configure the query and visualization settings as described
3. Click **"Save"** for each panel
4. When all panels are added, click **"Save Layout"**

---

### Section 1: Service Health & Overview

#### Panel 1.1: Total Request Rate (Requests/sec)

**Purpose**: Monitor overall system throughput across both applications

**Configuration**:
- **Panel Name**: `Total Request Rate`
- **Panel Type**: `Time Series`
- **Query Builder**:
  - **Metric**: `signoz_calls_total` 
  - **Legend Format**: `{{service_name}}`
  - **Aggregate**: `Rate`
  - **Group By**: `service_name`

**Alternative Query** (if above doesn't work):
- **Metric**: Look for `http_server_duration_count` or `http_requests_total`
- **Aggregate**: `Rate` 
- **Group By**: `service_name`

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Requests/sec`
- **Legend Position**: `Bottom`

---

#### Panel 1.2: Active Services

**Purpose**: Display number of active services reporting telemetry

**Configuration**:
- **Panel Name**: `Active Services`
- **Panel Type**: `Value`
- **Query**:
  - Navigate to **Services** page
  - Count should show 2 services: `otel-demo-app` and `otel-python-app`
  
**Note**: This is a visual reference panel. In Signoz, you can add a **custom markdown panel** or use the Services view to show this information.

---

#### Panel 1.3: Error Rate

**Purpose**: Track errors across all services

**Configuration**:
- **Panel Name**: `Error Rate (4xx/5xx)`
- **Panel Type**: `Time Series`
- **Query Builder**:
  - **Metric**: `signoz_calls_total`
  - **Filter**: `status_code` matches regex `^[45].*`
  - **Aggregate**: `Rate`
  - **Group By**: `service_name`, `status_code`

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Errors/sec`
- **Threshold**: Add warning line at 0.1

---

### Section 2: Performance Metrics

#### Panel 2.1: Request Latency - P50, P90, P99

**Purpose**: Visualize latency percentiles to identify performance issues

**Configuration**:
- **Panel Name**: `Request Latency (P50, P90, P99)`
- **Panel Type**: `Time Series`

**Query 1 - P50**:
- **Metric**: `signoz_latency_bucket` or `http_server_duration_bucket`
- **Aggregate**: `P50`
- **Group By**: `service_name`
- **Legend**: `{{service_name}} - P50`

**Query 2 - P90**:
- **Metric**: Same as above
- **Aggregate**: `P90`
- **Group By**: `service_name`
- **Legend**: `{{service_name}} - P90`

**Query 3 - P99**:
- **Metric**: Same as above
- **Aggregate**: `P99`
- **Group By**: `service_name`
- **Legend**: `{{service_name}} - P99`

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Latency (ms)`
- **Y-Axis Unit**: `milliseconds`

---

#### Panel 2.2: Requests by Endpoint

**Purpose**: See which endpoints are most frequently called

**Configuration**:
- **Panel Name**: `Top Endpoints by Request Count`
- **Panel Type**: `Table` or `Bar Chart`
- **Query Builder**:
  - **Metric**: `signoz_calls_total` or `http_requests_total`
  - **Aggregate**: `Sum` or `Count`
  - **Group By**: `service_name`, `http_route` (or `endpoint`)
  - **Order By**: `Descending`
  - **Limit**: `10`

**Visualization Settings**:
- **Chart Type**: `Bar Chart` (horizontal)
- **X-Axis Label**: `Request Count`

---

#### Panel 2.3: Service Comparison - Node.js vs Python

**Purpose**: Compare performance between Node.js and Python implementations

**Configuration**:
- **Panel Name**: `Average Response Time by Service`
- **Panel Type**: `Time Series`
- **Query Builder**:
  - **Metric**: `signoz_latency_sum` / `signoz_latency_count`
  - **Aggregate**: `Avg`
  - **Group By**: `service_name`

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Avg Response Time (ms)`
- **Compare**: Should show both `otel-demo-app` and `otel-python-app`

---

### Section 3: Custom Business Metrics

#### Panel 3.1: Dice Roll Distribution

**Purpose**: Visualize the distribution of dice roll values (custom metric)

**Configuration**:
- **Panel Name**: `Dice Roll Value Distribution`
- **Panel Type**: `Bar Chart` or `Histogram`
- **Query Builder**:
  - **Metric**: `dice_roll_value`
  - **Aggregate**: `Count`
  - **Group By**: Create buckets for values 1-6

**Alternative - Using Traces**:
If metric is not available, you can query traces:
- Go to **Traces** → **Filter by** `span.name = "roll-dice"`
- View attribute `dice.value` distribution

**Visualization Settings**:
- **Chart Type**: `Bar Chart`
- **X-Axis**: Values 1-6
- **Y-Axis Label**: `Count`

---

#### Panel 3.2: Endpoint Usage Breakdown

**Purpose**: Show percentage breakdown of endpoint calls

**Configuration**:
- **Panel Name**: `Endpoint Usage Distribution`
- **Panel Type**: `Pie Chart`
- **Query Builder**:
  - **Metric**: `http_requests_total` or `signoz_calls_total`
  - **Aggregate**: `Sum`
  - **Group By**: `http_route` or `endpoint`

**Expected Results**:
- `/` (root)
- `/rolldice`
- `/work`
- `/health`

---

#### Panel 3.3: Lucky Roll Events

**Purpose**: Count special events (rolling a 6)

**Configuration**:
- **Panel Name**: `Lucky Roll Events (Dice = 6)`
- **Panel Type**: `Value` or `Time Series`

**Using Traces**:
1. Go to **Traces** view
2. Filter: `span.name = "roll-dice"` AND `dice.value = 6`
3. Count over time

**Using Logs**:
- Navigate to **Logs**
- Filter: `message` contains `"Lucky six!"`
- Aggregate count over time

---

### Section 4: Distributed Tracing

#### Panel 4.1: Slowest Traces

**Purpose**: Identify performance bottlenecks

**Configuration**:
- **Panel Name**: `Top 10 Slowest Traces (Last Hour)`
- **Panel Type**: `Table`

**How to Create**:
1. Go to **Traces** tab
2. Filter by time range: `Last 1 hour`
3. Sort by: `Duration (Descending)`
4. Limit: `10`
5. Display columns: `Service`, `Operation`, `Duration`, `Timestamp`

**Insights to Look For**:
- `/work` endpoint should show nested spans (DB + API calls)
- Total duration should be ~350ms (200ms DB + 150ms API)

---

#### Panel 4.2: Service Dependencies

**Purpose**: Visualize service topology and dependencies

**Configuration**:
- **Panel Name**: `Service Dependency Graph`
- **Panel Type**: `Topology`

**How to Access**:
1. From sidebar, go to **Services**
2. Select **Service Map** view
3. You should see:
   - `otel-demo-app` → `signoz-otel-collector`
   - `otel-python-app` → `signoz-otel-collector`
   - Simulated dependencies (postgresql, external-api)

**Note**: This is typically accessed from the Services view rather than a custom dashboard panel.

---

#### Panel 4.3: Traces with Errors

**Purpose**: Monitor and debug errors in real-time

**Configuration**:
- **Panel Name**: `Recent Error Traces`
- **Panel Type**: `List` or `Table`

**How to Create**:
1. Go to **Traces** tab
2. Filter: `status = error` or `statusCode >= 400`
3. Time range: `Last 15 minutes`
4. Sort by: `Timestamp (Descending)`

---

### Section 5: Logs & Observability

#### Panel 5.1: Log Volume by Service

**Purpose**: Monitor log output across services

**Configuration**:
- **Panel Name**: `Log Volume Over Time`
- **Panel Type**: `Time Series`

**How to Create**:
1. Go to **Logs** view
2. Click **"Query Builder"** or **"ClickHouse Query"**
3. Query logs grouped by `service_name`
4. Aggregate: `Count`
5. Interval: `1 minute`

**Expected Services**:
- `otel-demo-app`
- `otel-python-app`

**Visualization Settings**:
- **Chart Type**: `Area` (stacked)
- **Y-Axis Label**: `Logs/min`

---

#### Panel 5.2: Logs by Severity

**Purpose**: Track log severity distribution (INFO, WARN, ERROR)

**Configuration**:
- **Panel Name**: `Log Severity Distribution`
- **Panel Type**: `Pie Chart` or `Bar Chart`

**Query**:
1. Go to **Logs** view
2. Group by: `severity_text` or `severityText`
3. Aggregate: `Count`
4. Time range: `Last 1 hour`

**Expected Severities**:
- `INFO` (majority)
- `ERROR` (if any errors occurred)

---

#### Panel 5.3: Correlated Logs Explorer

**Purpose**: Demonstrate trace-to-log correlation

**Configuration**:
- **Panel Name**: `Recent Logs with Trace Context`
- **Panel Type**: `Table`

**How to Create**:
1. Go to **Logs** view
2. Display columns:
   - `timestamp`
   - `service_name`
   - `message`
   - `trace_id`
   - `severity_text`
3. Filter: Logs with `trace_id` present
4. Sort by: `Timestamp (Descending)`

**Demonstration**:
- Click on any `trace_id` to jump directly to the associated trace
- This showcases the power of correlated observability!

---

### Section 6: Advanced Monitoring

#### Panel 6.1: Database Query Performance

**Purpose**: Monitor simulated database operations from `/work` endpoint

**Configuration**:
- **Panel Name**: `Database Query Duration (P95)`
- **Panel Type**: `Time Series`

**Using Traces**:
1. Go to **Traces** view
2. Filter: `span.name = "database-query"`
3. Aggregate: `P95` duration
4. Group by: `db.system` (should show "postgresql")

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Duration (ms)`
- **Expected Value**: ~200ms

---

#### Panel 6.2: External API Call Performance

**Purpose**: Monitor simulated external API calls

**Configuration**:
- **Panel Name**: `External API Call Duration (P95)`
- **Panel Type**: `Time Series`

**Using Traces**:
1. Go to **Traces** view
2. Filter: `span.name = "external-api-call"`
3. Aggregate: `P95` duration
4. Group by: `http.url`

**Visualization Settings**:
- **Chart Type**: `Line`
- **Y-Axis Label**: `Duration (ms)`
- **Expected Value**: ~150ms

---

#### Panel 6.3: Request Count by Method

**Purpose**: Monitor HTTP method distribution

**Configuration**:
- **Panel Name**: `HTTP Methods Distribution`
- **Panel Type**: `Pie Chart`
- **Query**:
  - **Metric**: `signoz_calls_total`
  - **Group By**: `http_method`
  - **Aggregate**: `Sum`

**Expected Results**:
- `GET` should be 100% for this demo

---

## 🎨 Dashboard Layout Recommendations

Organize your panels in a logical, professional layout:

```
┌─────────────────────────────────────────────────────────────┐
│  📊 OpenTelemetry Demo - Professional Overview              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Total Req/s  │  │ Active Svcs  │  │  Error Rate  │      │
│  │   (Line)     │  │   (Value)    │  │   (Line)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Request Latency P50/P90/P99 (Multi-line)         │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Top Endpoints       │  │  Service Comparison  │        │
│  │  (Bar Chart)         │  │  (Line Chart)        │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  Dice Distribution   │  │  Endpoint Usage      │        │
│  │  (Bar Chart)         │  │  (Pie Chart)         │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Log Volume Over Time (Area Chart)                │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐        │
│  │  DB Query Perf       │  │  API Call Perf       │        │
│  │  (Line)              │  │  (Line)              │        │
│  └──────────────────────┘  └──────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Tips**:
- Drag and drop panels to rearrange
- Resize panels by dragging corners
- Group related metrics together
- Put high-level metrics at the top
- Save layout when done

---

## 🔍 What Makes This Dashboard Professional?

### ✅ Comprehensive Coverage
- **Golden Signals**: Latency, Traffic, Errors, Saturation
- **Multi-dimensional**: Services, endpoints, operations
- **Full stack**: Application, infrastructure, business metrics

### ✅ Real-World Patterns
- **Percentile latencies** (P50, P90, P99) instead of just averages
- **Rate calculations** for throughput monitoring
- **Error tracking** separate from success metrics
- **Trace correlation** with logs

### ✅ Multi-Language Demonstration
- Side-by-side Node.js and Python comparison
- Identical instrumentation patterns
- Language-agnostic observability

### ✅ Business + Technical Metrics
- Technical: Latency, throughput, errors
- Business: Dice rolls, endpoint usage
- Custom: Database and API performance

---

## 🚦 Using Your Dashboard

### Generate Continuous Traffic

Keep your dashboard active with realistic traffic patterns:

```bash
# Run in background to generate continuous traffic
while true; do
  # Simulate user behavior
  curl -s http://otel-example.localhost/ > /dev/null
  sleep 1
  curl -s http://otel-example.localhost/rolldice > /dev/null
  sleep 2
  curl -s http://python-otel-example.localhost/work > /dev/null
  sleep 3
  curl -s http://python-otel-example.localhost/rolldice > /dev/null
  sleep 1
done
```

### Explore Trace Details

1. Click on any spike in the latency chart
2. Select **"View Traces"** to see individual requests
3. Click a trace to see:
   - Full request timeline
   - Nested spans (DB, API calls)
   - Custom attributes
   - Correlated logs

### Create Alerts

Turn your dashboard into an alerting system:

1. Click any panel's **"..."** menu
2. Select **"Create Alert"**
3. Set thresholds (e.g., "Error rate > 5%")
4. Configure notification channels

---

## 📸 Expected Results

After setup, your dashboard should show:

- ✅ **Request rates**: ~1-5 req/sec (depending on traffic generation)
- ✅ **Latencies**: 
  - Root `/`: ~100ms
  - RollDice: ~10-50ms
  - Work: ~350ms (DB 200ms + API 150ms)
- ✅ **Dice distribution**: Relatively even across 1-6
- ✅ **Services**: Both Node.js and Python apps reporting
- ✅ **Logs**: Structured JSON with trace IDs
- ✅ **Traces**: Nested spans visible in `/work` endpoint

---

## 🎯 Demo Talking Points

When showcasing this dashboard:

1. **Multi-Language Support**
   > "Notice how both Node.js and Python apps send identical telemetry with the same patterns - that's the power of OpenTelemetry's standardization."

2. **Three Pillars Integration**
   > "Click any trace to see correlated logs. The trace_id connects everything - metrics, traces, and logs work together."

3. **Custom Instrumentation**
   > "The dice roll distribution is a custom business metric. You can track anything that matters to your application."

4. **Real-World Patterns**
   > "We're monitoring P50, P90, and P99 latencies, not just averages. This catches edge cases and performance issues."

5. **Distributed Tracing**
   > "The /work endpoint shows nested spans - database queries and API calls. You can see exactly where time is spent."

6. **Production-Ready**
   > "This setup is demo-ready but uses production-grade patterns. Same instrumentation works from laptop to production."

---

## 🛠️ Troubleshooting

### No data appearing in panels?

1. **Check services are running**:
   ```bash
   kubectl get pods -n demo --kubeconfig kind/.kube/config
   ```

2. **Generate traffic** (panels need data):
   ```bash
   for i in {1..20}; do
     curl http://otel-example.localhost/rolldice
   done
   ```

3. **Verify time range**: Ensure dashboard time range includes recent data

### Metrics not found?

- Signoz metric names may vary by version
- Go to **Metrics Explorer** to see available metrics
- Common alternatives:
  - `signoz_calls_total` vs `http_requests_total`
  - `signoz_latency` vs `http_server_duration`

### Traces not showing?

1. Check OTEL Collector is running:
   ```bash
   kubectl get pods -n monitoring --kubeconfig kind/.kube/config | grep otel-collector
   ```

2. Check app logs for export errors:
   ```bash
   kubectl logs -n demo -l app.kubernetes.io/name=otel-demo-app --tail=50
   ```

---

## 🎓 Next Steps

After creating this dashboard, try:

1. **Create Custom Alerts**
   - Alert on high error rates
   - Alert on slow traces (P99 > 1s)
   - Alert on log volume spikes

2. **Explore Advanced Features**
   - Query Builder for custom metrics
   - ClickHouse queries for raw data
   - Dashboard variables for filtering

3. **Extend the Demo**
   - Add more endpoints with different behaviors
   - Simulate errors to test error tracking
   - Add service-to-service calls

4. **Export and Share**
   - Use Signoz's public sharing feature
   - Take screenshots for presentations
   - Create time-range snapshots

---

## 📚 Additional Resources

- **Signoz Documentation**: https://signoz.io/docs/
- **OpenTelemetry Semantic Conventions**: https://opentelemetry.io/docs/specs/semconv/
- **Query Builder Guide**: Check Signoz docs for latest query syntax
- **ClickHouse Functions**: For advanced analytics queries

---

## 🤝 Contributing

Have improvements for this dashboard?
- Add more panels showcasing different metrics
- Create alternative visualizations
- Share your custom queries

---

**Built for demonstration and learning**  
This dashboard showcases professional observability practices using open-source tools.
