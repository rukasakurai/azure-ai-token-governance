# Token governance sample

This repository is a standalone `azd` + Bicep sample for end-user token governance.

It demonstrates three approaches behind one Azure API Management (APIM) product:

| Approach | Enforcement | Usage source | Guarantee |
| --- | --- | --- | --- |
| Simple | APIM `llm-token-limit` | App Service query to Log Analytics | Immediate headers, delayed usage history |
| APIM-only | APIM `llm-token-limit` | APIM policy query to Log Analytics | No App Service query path |
| Strict | Atomic reservation + settlement | Azure Table Storage ledger | Authoritative committed + reserved usage |

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
- Strict endpoint supports one `user` text message and non-streaming calls only.
- APIM API diagnostic property for LLM token logs uses preview API `2025-09-01-preview`.
