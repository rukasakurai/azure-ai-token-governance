# Contributing

Thank you for contributing to the Azure AI token governance sample. This is the canonical contribution guide for both human contributors and automated tooling.

## Project scope

The repository demonstrates three token-governance approaches for Microsoft Foundry and Azure OpenAI Service using Azure Developer CLI (`azd`), Bicep, API Management, and a .NET 10 API. Keep changes focused on that sample and avoid production-platform features unrelated to the demonstrated approaches.

## Prerequisites

Install the .NET 10 SDK, Azure CLI, Azure Developer CLI (`azd`), `jq`, `curl`, and ShellCheck. Azure deployment validation also requires an authenticated subscription with permission to create the resources described in the README.

## Development guidelines

- Prefer small, surgical changes over new abstractions or additional infrastructure.
- Preserve support for both `AIServices` and `OpenAI` account kinds.
- Keep environment-specific Azure values in `azd` environment settings or GitHub configuration. Never commit tenant IDs, subscription IDs, credentials, or API keys.
- Keep billable token-governance resources opt-in through `ENABLE_TOKEN_USAGE_SAMPLE=true`.
- Update README or `docs/` content when deployment steps, configuration, API behavior, or limitations change.

## Local validation

Run the checks relevant to the files you changed:

```bash
dotnet test tests/token-usage-api/TokenUsage.Api.Tests.csproj
az bicep build --file infra/main.bicep --stdout >/dev/null
shellcheck scripts/*.sh
```

For deployment or integration changes, provision an isolated environment for the account kind being tested:

```bash
azd env new token-usage-e2e
azd env set AI_ACCOUNT_KIND AIServices   # or OpenAI
azd env set ENABLE_TOKEN_USAGE_SAMPLE true
azd up
./scripts/test-token-usage-e2e.sh --output /tmp/token-usage-result.json
azd down --purge --force
```

The GitHub Actions E2E workflow exercises both account kinds. Azure runs create billable resources, so always clean up test environments.

## Pull requests

Describe the behavior changed, the validation performed, and any Azure cost or compatibility impact. Keep pull requests narrow and do not include generated deployment state, local `azd` environment files, or sensitive output.
