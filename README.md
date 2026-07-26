# Azure AI token governance sample

Standalone Azure Developer CLI (`azd`) and Bicep sample for per-APIM-subscription token quota governance across:

- Microsoft Foundry (`AIServices` account kind)
- Azure OpenAI Service (`OpenAI` account kind)

## Governance framing

Token limits are one control within broader AI usage and cost governance. Cost
attribution should follow the expected source of value while preserving the
human, workload, organizational, and funding dimensions needed for different
decisions.

- [AI value realization and cost attribution](docs/value-realization-and-cost-attribution.md)
- [Azure token logging, alerting, and blocking capabilities](docs/azure-token-control-capabilities.md)
- [Evolution of AI usage and cost governance](docs/ai-usage-governance-history.md)

The product comparisons in these documents provide context; this repository's
runnable implementation remains limited to Foundry, Azure OpenAI, and APIM.

## Architecture

- One AI account + one model deployment (kind is parameterized)
- Optional sample stack (`ENABLE_TOKEN_USAGE_SAMPLE=true`):
  - Developer tier APIM with `llm-token-limit` policies
  - .NET 10 token usage API on App Service
  - Log Analytics + Application Insights for eventual usage reporting
  - Azure Table Storage ledger for authoritative quota accounting

## Deployment

```bash
azd env new token-usage-e2e
azd env set AI_ACCOUNT_KIND AIServices   # or OpenAI
azd env set ENABLE_TOKEN_USAGE_SAMPLE true
azd up
```

Default quotas are intentionally small to limit token consumption during testing:

- `SIMPLE_TOKEN_QUOTA=600`
- `STRICT_TOKEN_QUOTA=600`
- `STRICT_RESERVATION_TOKENS=256`
- `STRICT_MAX_OUTPUT_TOKENS=64`
- `STRICT_SAFETY_PADDING_TOKENS=64`

These limits do not cap the fixed hourly cost of deployed resources such as APIM Developer tier and App Service B1.

## APIs and tests

See [docs/token-usage.md](docs/token-usage.md) for endpoints and behavior.

Unit tests:

```bash
dotnet test tests/token-usage-api/TokenUsage.Api.Tests.csproj
```

Isolated end-to-end test:

```bash
./scripts/test-token-usage-e2e.sh --output /tmp/token-usage-result.json
```

## Limitations

- Simple and APIM-only usage endpoints are eventually consistent due to Log Analytics ingestion delay.
- Simple and APIM-only limits use post-response token accounting. Large or concurrent requests can exceed the configured quota before APIM records their usage.
- Quotas are scoped to APIM subscriptions. Per-user governance requires a separate subscription per user or an additional identity-to-subscription mapping layer.
- Strict mode is non-streaming and accepts exactly one `user` text message.
- Strict mode charges the full reservation when actual usage cannot be determined or a reservation expires. If reported backend usage exceeds its reservation, the complete usage is recorded and can take the period total above the configured quota.
- This is a demonstration sample and intentionally omits production platform hardening beyond the three approaches.

## Costs incurred

With `ENABLE_TOKEN_USAGE_SAMPLE=true`, this deploys billable resources including APIM Developer tier, App Service plan, Log Analytics, Application Insights, Storage account, and AI account/model deployment usage.

With `ENABLE_TOKEN_USAGE_SAMPLE=false`, APIM/App Service/observability/ledger resources are not deployed.

## Teardown

```bash
azd down --purge --force
```

## License

Licensed under the [MIT License](LICENSE).
