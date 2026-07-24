# Token governance sample

This repository is a standalone `azd` + Bicep sample for per-APIM-subscription token quota governance.

It demonstrates three approaches behind one Azure API Management (APIM) product:

| Approach | Enforcement | Usage source | Guarantee |
| --- | --- | --- | --- |
| Simple | APIM post-response token accounting | App Service query to Log Analytics | Best-effort monthly limit; delayed usage history |
| APIM-only | APIM post-response token accounting | APIM policy query to Log Analytics | Best-effort monthly limit; no App Service query path |
| Strict | Atomic reservation + settlement | Azure Table Storage ledger | Authoritative quota accounting for committed + reserved tokens |

The same APIM policies, reporting API, and strict ledger are shared across both account products:

- **Microsoft Foundry account** (`AIServices` kind)
- **Azure OpenAI Service account** (`OpenAI` kind)

## Deploy

Requirements: Azure CLI, Azure Developer CLI (`azd`), .NET 10, and access to deploy APIM/App Service/Cognitive Services resources.

```bash
azd env new token-usage-e2e
azd env set AI_ACCOUNT_KIND AIServices   # or OpenAI
azd env set ENABLE_TOKEN_USAGE_SAMPLE true
azd up
```

`ENABLE_TOKEN_USAGE_SAMPLE=false` (default) avoids APIM deployment/cost.

Small token quotas limit model consumption, not fixed infrastructure charges. Enabling the sample deploys billable resources including APIM Developer tier and App Service B1.

## Run isolated E2E

```bash
./scripts/test-token-usage-e2e.sh \
  --simple-requests 3 \
  --parallel-requests 6 \
  --output /tmp/token-usage-result.json
```

The script creates and deletes an isolated APIM subscription key for each run.

## API surface

All operations require `Ocp-Apim-Subscription-Key`.

Quota state is keyed by APIM subscription. To enforce a separate quota for each end user, issue a distinct subscription per user or add an authenticated identity-to-subscription mapping layer; this sample does not implement end-user authentication.

| Operation | Purpose |
| --- | --- |
| `POST /token-usage/simple/chat/completions` | Non-streaming chat with APIM token limit |
| `GET /token-usage/simple/usage` | Current-month usage via App Service + Log Analytics |
| `POST /token-usage/apim-only/chat/completions` | Non-streaming chat with APIM-only reporting path |
| `GET /token-usage/apim-only/usage` | Current-month usage directly from APIM policy query |
| `POST /token-usage/strict/chat/completions` | Non-streaming chat with atomic reservation/settlement |
| `GET /token-usage/strict/usage` | Authoritative used/reserved/remaining state |

## Limitations

- Usage for simple/APIM-only paths is eventually consistent (Log Analytics ingestion delay).
- Simple/APIM-only quota usage is recorded after backend responses, so large or concurrent requests can exceed the configured limit before APIM observes their usage.
- Strict endpoint supports one `user` text message and non-streaming calls only.
- Strict accounting charges the full reservation when actual usage cannot be determined or a reservation expires. Reported backend usage greater than the reservation is recorded in full and can take the period total above the configured quota.
- APIM API diagnostic property for LLM token logs uses preview API `2025-09-01-preview`.
