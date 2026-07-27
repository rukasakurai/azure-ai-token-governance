# Azure token control and consumer visibility capabilities

> **Scope warning:** This independent personal project is not an official
> Microsoft or GitHub publication and does not represent the positions of
> either company or any employer. This is a point-in-time capability analysis,
> not a production architecture or guarantee of cost containment. Enforcement
> accuracy depends on identity, routing, concurrency, streaming behavior,
> gateway topology, and whether callers can bypass the governed path.

| Governance scope | What the scope means | Log consumed tokens | Alert when a token threshold is exceeded | Block further use after a token threshold is exceeded |
| --- | --- | --- | --- | --- |
| Single model request | One call from a client or agent to a language-model API | **Mechanism:** APIM request telemetry.<br>**Requires:** Azure management-plane configuration to enable generative-AI diagnostics and a Log Analytics destination.<br>**Limitation:** final token data can be absent or inaccurate for interrupted streams. | **Mechanism:** Azure Monitor log alert.<br>**Requires:** Azure management-plane configuration of a query, threshold, evaluation frequency, and action group.<br>**Limitation:** evaluation occurs after telemetry ingestion and cannot prevent the triggering request. | **Mechanism:** APIM pre-request guard with post-response accounting.<br>**Requires:** an APIM data-plane policy deployed through the Azure management plane; prompt estimation or request caps can strengthen the guard.<br>**Limitation:** final output tokens are unknown before completion, so an exact per-request total-token cap is unavailable. |
| APIM subscription | All calls made with one Azure API Management subscription | **Mechanism:** APIM-native subscription attribution.<br>**Requires:** Azure management-plane configuration of diagnostics or token metrics; no application or Entra change.<br>**Limitation:** observed usage inherits APIM's streaming and response-completion accuracy limits. | **Mechanism:** Azure Monitor alert on the APIM subscription dimension.<br>**Requires:** Azure management-plane configuration of token metrics or logs, an alert rule, and an action group.<br>**Limitation:** notification is asynchronous. | **Mechanism:** APIM gateway-local token quota keyed by subscription ID.<br>**Requires:** an APIM `llm-token-limit` data-plane policy deployed through the Azure management plane.<br>**Limitation:** concurrent requests can overshoot, and regional or workspace gateways maintain separate counters. |
| APIM product, API, or operation | Traffic assigned to a gateway-native workload boundary | **Mechanism:** APIM-native workload attribution.<br>**Requires:** Azure management-plane configuration of diagnostics or token metrics; no application or Entra change.<br>**Limitation:** the boundary reflects APIM configuration, not necessarily the logical business workload. | **Mechanism:** Azure Monitor alert on an APIM-native workload dimension.<br>**Requires:** Azure management-plane configuration of token telemetry, an alert rule, and an action group.<br>**Limitation:** notification is asynchronous. | **Mechanism:** APIM gateway-local token quota keyed by native gateway context.<br>**Requires:** a scope-specific APIM data-plane policy and distinct counter key, deployed through the Azure management plane.<br>**Limitation:** concurrent overshoot and gateway-local counters still apply. |
| Model deployment and Azure subscription capacity | Consumption of a model or deployment within Azure's provider quota scope | **Mechanism:** Azure OpenAI platform metrics.<br>**Requires:** no application change; Azure management-plane configuration is needed only for export or longer-term centralized analysis.<br>**Limitation:** metrics are aggregated platform telemetry, not an authoritative request ledger. | **Mechanism:** Azure Monitor metric alert.<br>**Requires:** Azure management-plane configuration of model or deployment dimensions, threshold, and action group.<br>**Limitation:** the alert evaluates aggregate capacity telemetry rather than a business budget. | **Mechanism:** Foundry provider-capacity throttle.<br>**Requires:** deployment quota allocation through the Azure management plane; no application change.<br>**Limitation:** TPM/RPM throttling protects provider capacity and is not a cumulative token or financial budget. |
| Authenticated individual | One person, including callers that might share an APIM subscription or application credential | **Mechanism:** token telemetry enriched with validated user identity.<br>**Requires:** a trustworthy identity path; with Entra, this normally combines application registration, client or application authentication, APIM token validation and claim extraction, and propagation into telemetry.<br>**Limitation:** Azure cannot distinguish individuals when only a shared subscription key or workload credential is presented. | **Mechanism:** Azure Monitor query alert grouped by validated user identity.<br>**Requires:** the same trusted identity path plus Azure management-plane configuration of the query, threshold, and action group.<br>**Limitation:** identity-aware notification remains asynchronous. | **Mechanism:** APIM gateway-local quota keyed by validated user identity.<br>**Requires:** trusted user authentication and claim validation, commonly through Entra, plus an APIM `llm-token-limit` data-plane policy.<br>**Limitation:** shared-key-only callers remain indistinguishable; concurrent overshoot and gateway-local counters apply. |
| Application or agent | One logical workload or agent, including workloads that might share infrastructure or credentials | **Mechanism:** gateway-mapped or instrumented workload attribution.<br>**Requires:** either a one-to-one APIM product, API, subscription, or backend mapping, or application/agent code that propagates a trusted workload identifier through headers or OpenTelemetry; Entra workload identity can strengthen trust.<br>**Limitation:** Azure does not infer the logical workload when credentials or intermediaries are shared. | **Mechanism:** Azure Monitor alert grouped by workload identity.<br>**Requires:** consistent gateway mapping or application instrumentation plus Azure management-plane configuration of the alert rule and action group.<br>**Limitation:** attribution quality depends on the supplied workload identity, and notification is asynchronous. | **Mechanism:** APIM gateway-local quota keyed by workload identity.<br>**Requires:** a gateway-native mapping or a trusted application-supplied identity plus an APIM data-plane policy.<br>**Limitation:** shared or spoofable identifiers weaken isolation; concurrent overshoot and gateway-local counters apply. |
| Task, session, or agent run | One bounded execution or user interaction whose lifecycle is defined by the application | **Mechanism:** application-correlated execution telemetry.<br>**Requires:** application or agent code that creates and propagates a task, session, or run identifier through OpenTelemetry and, when APIM correlation is needed, a trusted request header.<br>**Limitation:** Azure does not define the execution lifecycle or guarantee complete correlation. | **Mechanism:** Azure Monitor query alert grouped by execution identifier.<br>**Requires:** application instrumentation plus Azure management-plane configuration of a log query, threshold, evaluation frequency, and action group.<br>**Limitation:** the alert is post-consumption and depends on complete correlation. | **Mechanism:** APIM fixed-window quota or custom lifecycle enforcement.<br>**Requires:** application propagation of a trusted execution identifier and an APIM policy for approximation; exact task-lifecycle enforcement requires a custom Azure resource data-plane ledger or reservation service.<br>**Limitation:** APIM's fixed quota periods do not reset when an arbitrary task or run ends. |
| Team, department, cost center, product, or business unit | An organizational or financial owner defined outside APIM | **Mechanism:** token telemetry enriched with organizational ownership.<br>**Requires:** customer-owned mapping from user or workload identity to an owner, using Entra groups and/or business master data, plus application or APIM enrichment of telemetry.<br>**Limitation:** Azure does not maintain the complete business hierarchy, effective dates, or allocation rules. | **Mechanism:** Azure Monitor query alert grouped by organizational owner.<br>**Requires:** the same identity mapping and enrichment plus Azure management-plane configuration of queries, thresholds, and action groups.<br>**Limitation:** alert correctness follows the freshness and completeness of customer-owned mappings. | **Mechanism:** APIM owner-keyed quota or custom shared enforcement.<br>**Requires:** trusted owner resolution plus an APIM data-plane policy; exact enforcement across gateways requires a custom Azure resource data-plane ledger or reservation service.<br>**Limitation:** APIM does not supply organizational mappings, and its counters are gateway-local. |
| Enterprise or tenant | All relevant AI consumption across subscriptions, regions, gateways, and applications | **Mechanism:** customer-consolidated enterprise telemetry.<br>**Requires:** Azure management-plane deployment of diagnostics across resources and subscriptions; a centralized or cross-workspace Log Analytics design, or exported data; a common schema; and application instrumentation for traffic lacking native dimensions.<br>**Limitation:** Azure does not automatically create a complete tenant-wide token dataset. | **Mechanism:** Azure Monitor alert over consolidated telemetry.<br>**Requires:** the same collection architecture plus centrally managed cross-resource queries, thresholds, and action groups.<br>**Limitation:** coverage and timeliness depend on customer-standardized collection and workspace design. | **Mechanism:** custom distributed hard limit.<br>**Requires:** routing governed traffic through enforcement points backed by a custom globally shared ledger or reservation service in an Azure resource data plane.<br>**Limitation:** Azure has no native tenant-global token counter, and traffic outside the governed path is not covered. |

This assessment is current through 2026-07-27 and concerns token consumption
through Microsoft Foundry or Azure OpenAI APIs, particularly when Azure API
Management (APIM) is used as the gateway.

## How to read the table

The three capabilities are deliberately separate:

- **Log consumed tokens** means Azure can persist token-consumption telemetry
  that an administrator can query after a request. A log or metric is
  observational data; it is not necessarily complete enough to serve as an
  authoritative quota ledger.
- **Alert when a token threshold is exceeded** means Azure Monitor can evaluate
  logged or metric data and invoke an action group, such as email, SMS, a
  webhook, an Azure Function, or a Logic App. An alert is asynchronous and does
  not itself stop the request that caused it
  ([Azure Monitor alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)).
- **Block further use after a token threshold is exceeded** means a native Azure
  enforcement point can reject later requests for that scope. It does not mean
  the limit is an exact financial cap: APIM can learn final output-token usage
  only after receiving a response, and concurrent requests can temporarily
  overshoot a limit
  ([APIM `llm-token-limit`](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#considerations-for-token-counts-and-estimation)).

Each capability cell uses the same structure:

- **Mechanism:** the Azure feature or custom architecture that supplies the
  capability.
- **Requires:** the customization needed across the Azure management plane,
  APIM or another Azure resource data plane, Entra, application or agent code,
  organizational data, or a combination of them.
- **Limitation:** the most important boundary that remains after implementing
  the requirement.

In this document, **Azure management plane** means configuration performed
through ARM, Bicep, the Azure portal, CLI, PowerShell, or equivalent control
APIs. **APIM data-plane policy** means policy logic executed synchronously by
the gateway for API traffic. A **custom Azure resource data-plane ledger or
reservation service** means customer-written stateful enforcement running on
services such as Azure Storage, Cosmos DB, or another transactional data store;
it is not an out-of-the-box token-governance feature.

The table describes representative implementations for Azure OpenAI traffic,
especially traffic routed through APIM. Equivalent identity providers,
telemetry pipelines, or data stores can satisfy some requirements, but they do
not change the stated responsibility or limitation.

## Consumer-facing governance capabilities

The matrix above describes controls available to platform administrators and
application owners. A consumer without Azure portal access or Azure RBAC can
still observe and respond to some quota state through the API contract, but
only when the organization exposes that information.

| Consumer need | Available Azure or APIM surface | What the organization must configure or build | Boundary |
| --- | --- | --- | --- |
| See tokens consumed by the current request | APIM can add a response header containing the prompt and completion tokens consumed by the request. | Configure `tokens-consumed-header-name` in the APIM `llm-token-limit` policy and document the chosen header name. | The header is added only after the backend response. Streaming responses use estimates, and interrupted responses can produce incomplete or inaccurate counts ([policy attributes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes), [token-count considerations](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#considerations-for-token-counts-and-estimation)). |
| See the remaining short-term rate allowance | APIM can add a response header containing the remaining tokens in the rate-limit interval. | Configure `remaining-tokens-header-name` and make the header part of the consumer API contract. | The value represents the configured APIM counter and gateway, not a provider-wide or enterprise-wide allowance ([policy attributes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes), [gateway-local counters](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#usage-notes)). |
| See the remaining periodic quota | APIM can add a response header containing the estimated tokens remaining in the hourly, daily, weekly, monthly, or yearly quota period. | Configure `remaining-quota-tokens-header-name` and disclose which identity or subscription the counter represents. | Microsoft documents the remaining quota as an estimate that can be higher than expected until the quota is approached ([policy attributes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes), [remaining-quota accuracy](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#usage-notes)). |
| Understand a rejection and know when to retry | APIM returns `429 Too Many Requests` for a token rate violation and `403 Forbidden` for a periodic token quota violation. It can return a `Retry-After` header. | Configure the policy and, if needed, a custom retry-header name and consumer-facing error body. | The status and retry interval identify the immediate gateway decision; they do not explain organizational ownership, funding, or whether another gateway has separate capacity ([APIM token limits](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy)). |
| Know the configured quota limit | The documented `llm-token-limit` response surface has no attribute that automatically emits the configured `token-quota` value. | Publish the limit in API documentation, add a custom response header, or return it from a protected usage endpoint. | A separately published limit can drift from policy configuration unless both are deployed from the same source of truth ([policy statement and attributes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#policy-statement)). |
| Know when the quota period resets | APIM defines fixed UTC hourly, daily, weekly, monthly, or yearly periods and can return a retry interval after a limit is exceeded. | Expose the period and calculated reset time through documentation, a custom response header, or a protected usage endpoint. | The documented policy does not provide an always-present absolute reset timestamp to the consumer ([quota-period attribute](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes)). |
| Query current-period usage outside an individual request | This repository demonstrates protected `GET /usage` endpoints for APIM subscription-scoped state. | Build and authorize a query API over APIM logs or an authoritative ledger, as demonstrated by the [sample API surface](token-usage.md#api-surface). | The documented APIM policy exposes headers and policy variables during request processing but does not document a consumer query operation for its internal token counter ([APIM token-limit policy](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy)). |
| View historical usage by day or model | APIM generative-AI logs contain token consumption and model-deployment details that administrators can query in Log Analytics. | Build a protected consumer API or interface that filters the administrative telemetry to the caller's authorized scope. | Direct Log Analytics or Azure portal access is an administrator/developer experience and can expose data outside the consumer's scope if authorization is not added carefully ([APIM language-model logging](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-llm-logs)). |
| Receive threshold notifications | Azure Monitor action groups can send email, SMS, push, webhook, or other notifications when an alert fires. | An administrator must create the alert and action group, or the organization must build a delegated notification-preference experience. | The documented Azure Monitor alert surface is administrator-configured and does not describe a token-specific consumer self-service subscription experience ([Azure Monitor alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)). |
| Understand whether usage is personal or shared | Response headers reflect the `counter-key` selected by the APIM policy. | Disclose the quota scope in documentation or a response field and propagate a validated individual identity if personal attribution is intended. | A shared APIM subscription key produces shared state unless the policy uses another trustworthy identity for its counter ([counter-key behavior](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes)). |
| Respond to approaching or exhausted limits | A client can delay requests based on `Retry-After`, reduce optional work, or stop submitting requests. | The client or application must expose and implement those choices; APIM supplies signals and enforcement, not the consumer workflow. | Consumers cannot change the configured quota or counter scope through the `llm-token-limit` response surface ([APIM token limits](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy)). |

Response headers are useful per-request signals, but they are not a complete
self-service usage experience. A durable consumer view normally needs an
authorized read model that reports the limit, used and remaining amounts,
period boundaries, scope, and any permitted history from one consistent source.
This section describes documented current surfaces and makes no claim about
future product roadmaps or undisclosed plans.

## Native request and gateway scopes

### Single model request

APIM can write an `ApiManagementGatewayLlmLog` record containing prompt,
completion, and total token consumption, the model deployment, and a
correlation identifier. This is native request-level logging
([APIM language-model logging](https://learn.microsoft.com/en-us/azure/api-management/api-management-howto-llm-logs)).

Azure Monitor can evaluate individual log rows or aggregate a numeric token
column and trigger an alert when a request or a time-window total crosses a
threshold
([log search alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-create-log-alert-rule)).

APIM can reject a request when a counter is already exhausted and can estimate
prompt tokens before forwarding the request, but the final completion-token
count is unknown until the model responds. Streaming responses also require
estimation. APIM can therefore reduce excess consumption but cannot guarantee
that the actual total tokens produced by one request stay below an exact
pre-request threshold
([APIM token-count considerations](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#considerations-for-token-counts-and-estimation)).

### APIM subscription

An APIM subscription requires the least customer-defined attribution among the
business-consumer scopes in this matrix. APIM already knows the subscription
identifier, can include it as a default token-metric dimension, and can use it
directly as the `llm-token-limit` counter key
([APIM token metrics](https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy#default-dimension-names-that-may-be-used-without-value),
[APIM subscription quota example](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#token-quota)).

Azure Monitor can alert on the emitted subscription dimension, while APIM can
return `403 Forbidden` after a periodic token quota is exceeded or `429 Too Many
Requests` after a token rate is exceeded
([APIM `llm-token-limit`](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy)).

Logging, threshold evaluation, and subsequent rejection use native APIM and
Azure Monitor mechanisms after management-plane configuration. This does not
make the APIM counter an exact, globally consistent ledger: concurrent calls
can overshoot, and counters are maintained independently at each regional or
workspace gateway
([APIM token-limit usage notes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#usage-notes)).

### APIM product, API, or operation

APIM exposes product ID, API ID, and operation ID as default dimensions for
token metrics
([APIM token metrics](https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy#default-dimension-names-that-may-be-used-without-value)).
Policies can also be applied at global, workspace, product, API, and operation
scopes. A policy expression can construct a distinct counter key for the
desired workload boundary
([APIM policy scopes](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#usage)).

APIM supplies these identifiers itself, so logging, alerting, and blocking can
operate on them without an external identity mapping.

## Provider capacity scope

### Model deployment and Azure subscription capacity

Azure Monitor automatically collects Azure OpenAI request and token metrics.
The metrics can be split by model deployment, model name, model version,
region, operation, and other dimensions, and Azure Monitor can alert on those
metrics
([Azure OpenAI monitoring reference](https://learn.microsoft.com/en-us/azure/foundry/openai/monitor-openai-reference)).

Azure also enforces provider capacity through tokens-per-minute and
requests-per-minute quotas. These quotas are scoped by Azure subscription,
region, and model or deployment type; they are not tenant-level quotas
([Azure OpenAI quota scope](https://learn.microsoft.com/en-us/azure/foundry/openai/quotas-limits#scope-of-quota)).

Provider quota protects service capacity rather than enforcing a customer's
cumulative token budget. It can throttle traffic when TPM or RPM capacity is
exhausted, but it does not natively implement a monthly token allowance for a
deployment, subscription, or business owner. APIM can add such a quota for
traffic routed through a gateway, subject to APIM's estimation, concurrency,
and gateway-local counter limitations.

## Customer-supplied identity and correlation scopes

### Authenticated individual

> **Responsible use:** Individual attribution supports cost and system
> governance; it is not a standalone measure of employee productivity or
> performance. See
> [AI value realization and cost attribution](value-realization-and-cost-attribution.md#avoid-misusing-individual-attribution).

Application Insights supports authenticated user identifiers, and APIM token
metrics can use APIM's `User ID` dimension, which identifies APIM's own user
entity and is not necessarily an Entra-validated identity, or a custom
policy-expression dimension
([Application Insights user analysis](https://learn.microsoft.com/en-us/azure/azure-monitor/app/usage#track-user-interactions-with-custom-events),
[APIM token dimensions](https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy)).
Azure Monitor can then aggregate and alert by that identifier, and APIM can use
the same identifier as a token-limit counter key. APIM can validate a Microsoft
Entra token and expose its claims to later policy expressions
([APIM Entra token validation](https://learn.microsoft.com/en-us/azure/api-management/validate-azure-ad-token-policy)).

Azure cannot infer the individual behind a shared APIM subscription key. The
client or application must authenticate the person, and APIM must validate and
propagate a trustworthy stable identifier, such as an Entra object ID claim,
into the telemetry and counter key. Once that identity path exists, APIM and
Azure Monitor supply the token logging, alerting, and gateway-local blocking
mechanisms.

### Application or agent

Application Insights provides an Agent details experience that can display
agent executions, model and tool calls, token use, and cost. The experience
requires agent telemetry collection based on OpenTelemetry generative-AI
semantics
([Application Insights agent monitoring](https://learn.microsoft.com/en-us/azure/azure-monitor/app/agents-view)).

APIM can log, alert, and enforce a token counter for an application or agent if
its stable identity is available in the request or is represented by a
gateway-native API, product, subscription, or backend identifier. Azure does
not automatically map every call to the logical application or agent that
caused it, particularly when several workloads share credentials or call
through an intermediary.

### Task, session, or agent run

Application Insights can correlate telemetry into operations and sessions, and
its Agent details view can inspect individual agent executions
([Application Insights telemetry correlation](https://learn.microsoft.com/en-us/azure/azure-monitor/app/data-model-complete),
[agent run traces](https://learn.microsoft.com/en-us/azure/azure-monitor/app/agents-view#investigate-traces)).
Azure Monitor can alert on the resulting logs or metrics.

Azure does not know the lifecycle of an arbitrary business task or session
unless the application instruments and propagates a correlation identifier.
APIM can use that identifier as a counter key, but its native quota periods are
fixed hourly, daily, weekly, monthly, or yearly windows—not "until this task or
run ends"
([APIM quota periods](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#attributes)).

### Team, department, cost center, product, or business unit

APIM token metrics support up to five customer-defined dimensions, so an
organization can emit a team, cost-center, product, or business-unit identifier
and use Azure Monitor to aggregate and alert on it
([APIM custom token dimensions](https://learn.microsoft.com/en-us/azure/api-management/llm-emit-token-metric-policy#limits-for-custom-metrics)).
The same stable identifier can be used as an APIM token-limit counter key.

APIM does not maintain the organization's identity-to-team hierarchy,
cost-center assignments, product ownership, or effective-dating rules. The
customer must supply and govern that mapping. Microsoft Cost Management can
organize monetary costs by Azure resource hierarchy, tags, and allocation
rules, but those features operate on Azure billing records rather than
maintaining request-level token counters
([Cost Management allocation](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-allocation-introduction)).

## Enterprise or tenant scope

Azure can centralize logs from multiple resources and subscriptions in Log
Analytics, and Azure Monitor can evaluate cross-resource log queries. This
supports enterprise reporting and alerting for the traffic that has been
instrumented and routed into the selected workspaces
([Azure Monitor log alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-create-log-alert-rule)).

Azure does not automatically produce one tenant-wide token dataset covering
every model provider, subscription, region, gateway, direct endpoint,
application, and identity. The organization must standardize collection and
consolidate the data before enterprise reporting and alerting are complete.

Azure OpenAI quota is not enforced at tenant scope, and APIM token counters are
maintained separately by gateway rather than aggregated across an APIM instance
or enterprise
([Azure OpenAI quota scope](https://learn.microsoft.com/en-us/azure/foundry/openai/quotas-limits#scope-of-quota),
[APIM gateway-local counters](https://learn.microsoft.com/en-us/azure/api-management/llm-token-limit-policy#usage-notes)).
A centrally mandated gateway can narrow the problem, but it does not create a
native, globally consistent tenant-wide token counter.

## Alerts and budgets are not enforcement

Azure Monitor alerts can initiate automation, but an alert-driven workflow is
not equivalent to synchronous quota enforcement. Telemetry ingestion,
evaluation, notification, and automation all occur after consumption has
happened.

Microsoft Cost Management budgets are even less suitable for token blocking:
cost and usage data is typically delayed by 8 to 24 hours, budgets are evaluated
every 24 hours, and Microsoft explicitly states that budget notifications do
not affect resources or stop consumption
([Cost Management budgets](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)).

For a strict enterprise limit across concurrent requests or distributed
gateways, an organization needs an authoritative shared ledger or reservation
service. The strict approach in this repository demonstrates that architecture
for one APIM-subscription quota scope; it is not an out-of-the-box Azure
capability.
