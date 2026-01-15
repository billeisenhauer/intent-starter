# Monitoring

Observable contracts.

## Required Content

### metrics.md

Defines how metrics are computed:
- Source
- Definition
- Unit

### slo.md

Defines what success looks like:
- Target threshold
- Alert condition
- Time window

## Forbidden Content

- Implementation details
- Alerting infrastructure
- Dashboard specifications
- Tool-specific configuration

If it describes *how to observe* rather than *what must be observed*,
it does not belong here.
