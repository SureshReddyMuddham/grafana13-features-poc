# Grafana 13 Features POC

A hands-on testing environment for **Grafana 13.1.0** features running locally on Docker. Includes 2 Node.js microservices generating traces, metrics, logs, and profiles for testing.

> **Walkthrough**: See [Exploring Grafana Assistant](docs/GRAFANA-ASSISTANT-JOURNEY.md) for a detailed journey of testing the AI-powered Assistant, with screenshots showing dashboard generation, RCA, and alert rule creation.

## What's New in Grafana 13

This POC tests the following Grafana 13 features ([release notes](https://grafana.com/docs/grafana/latest/whatsnew/whats-new-in-v13-0/)):

### AI-Powered

- **Grafana Assistant  — AI agent for analyzing telemetry, building dashboards, writing code

### Infrastructure & Operations

- **Git Sync for Dashboards/Folders** (GA) — Bidirectional GitOps
- **Grafana Advisor** (GA) — Health checks for plugins, data sources, SSO
- **Provenance Support for Alerting APIs** (GA)

### Data Sources

- **Elasticsearch raw query editor** (GA on OSS/Enterprise)
- **IBM DB2 Data Source** (Public Preview)

## Architecture

```
┌──────────────┐  ┌─────────────────┐
│  orders-api  │  │ payment-service │   OTel SDK
└──────┬───────┘  └────────┬────────┘
       └─────────┬─────────┘
                 ▼
       ┌──────────────────┐         ┌────────────────┐
       │  OTel Collector  │ ◄──────│  eBPF Profiler  │
       │  (contrib v0.149)│  OTLP   │  (kernel-level) │
       └──┬───┬────┬───┬──┘         └────────────────┘
          │   │    │   │
          ▼   ▼    ▼   ▼
      ┌────┐┌────┐┌────┐┌──────────┐
      │Prom││Loki││Tempo││Pyroscope │
      └─┬──┘└─┬──┘└─┬──┘└────┬─────┘
        └────┴─────┴─────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  Grafana 13.1   │
        │  + Assistant AI │
        └─────────────────┘
```

## Quick Start

```bash
# Start the full stack (9 containers)
docker compose up -d

# Wait ~30s for all services to be ready, then generate traffic
./generate-traffic.sh 60

# Open Grafana 13
open http://localhost:3001
# Login: admin / admin
```

## Access URLs

| Service | URL | Notes |
|---------|-----|-------|
| **Grafana 13** | http://localhost:3001 | admin/admin |
| Prometheus | http://localhost:9090 | metrics |
| Loki | http://localhost:3100 | logs |
| Tempo | http://localhost:3200 | traces |
| Pyroscope | http://localhost:4040 | profiles |
| Orders API | http://localhost:3000 | demo service |
| Payment Service | http://localhost:3002 | demo service |
| OTel Collector | http://localhost:8888/metrics | self-metrics |

## Project Structure

```
.
├── docker-compose.yaml           # 9 services
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/          # Prometheus, Loki, Tempo, Pyroscope
│   │   └── dashboards/           # Dashboard provisioning
│   └── dashboards/               # Dashboard JSON files
├── prometheus/prometheus.yml
├── loki/loki-config.yml
├── tempo/tempo.yml
├── pyroscope/pyroscope.yaml
├── otel-collector/
│   ├── config.yaml               # Main collector
│   └── ebpf-profiler-config.yaml # eBPF → Collector
├── app/                          # orders-api (Node.js)
├── payment-service/              # payment-service (Node.js)
└── generate-traffic.sh           # Traffic generator
```

## Telemetry Stack

| Signal | Pipeline |
|--------|----------|
| **Traces** | App (OTel SDK) → OTel Collector → Tempo |
| **Metrics** | App (OTel SDK) + docker_stats → OTel Collector → Prometheus |
| **Logs** | App (OTel Logs API) → OTel Collector → Loki |
| **Profiles** | OTel eBPF Profiler → OTel Collector → Pyroscope |

## Stop the Stack

```bash
docker compose down -v
```

## References

- [Grafana 13 Release Notes](https://grafana.com/docs/grafana/latest/whatsnew/whats-new-in-v13-0/)
- [Grafana Assistant Setup](https://grafana.com/docs/grafana-cloud/machine-learning/assistant/on-premise/)
- [Dynamic Dashboards](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/manage-dashboard-objects/)
- [Git Sync](https://grafana.com/docs/grafana/latest/dashboards/share-dashboards-panels/git-sync/)
