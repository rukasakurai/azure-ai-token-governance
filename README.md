# Azure AI token governance sample

Standalone Azure Developer CLI (`azd`) and Bicep sample for end-user token governance across:

- Microsoft Foundry (`AIServices` account kind)
- Azure OpenAI Service (`OpenAI` account kind)

## Architecture

- One AI account + one model deployment (kind is parameterized)
- Optional sample stack (`ENABLE_TOKEN_USAGE_SAMPLE=true`):
  - Developer tier APIM with `llm-token-limit` policies
  - .NET 10 token usage API on App Service
  - Log Analytics + Application Insights for eventual usage reporting
  - Azure Table Storage authoritative ledger for strict quota

## Deployment

```bash
azd env new token-usage-e2e
azd env set AI_ACCOUNT_KIND AIServices   # or OpenAI
azd env set ENABLE_TOKEN_USAGE_SAMPLE true
azd up
```

Default quotas are intentionally small for low-cost testing:

- `SIMPLE_TOKEN_QUOTA=600`
- `STRICT_TOKEN_QUOTA=600`
- `STRICT_RESERVATION_TOKENS=256`
- `STRICT_MAX_OUTPUT_TOKENS=64`
- `STRICT_SAFETY_PADDING_TOKENS=64`

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
- Strict mode is non-streaming and accepts exactly one `user` text message.
- This is a demonstration sample and intentionally omits production platform hardening beyond the three approaches.

## Costs incurred

With `ENABLE_TOKEN_USAGE_SAMPLE=true`, this deploys billable resources including APIM Developer tier, App Service plan, Log Analytics, Application Insights, Storage account, and AI account/model deployment usage.

With `ENABLE_TOKEN_USAGE_SAMPLE=false`, APIM/App Service/observability/ledger resources are not deployed.

## Teardown

```bash
azd down --purge --force
```
