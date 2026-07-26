# Evolution of AI usage and cost governance

> **Point-in-time notice:** Product availability, meters, prices, and
> administrative controls change frequently. Verify current vendor
> documentation before making purchasing or governance decisions; cited
> announcements are not evidence of future roadmap commitments.

This document traces how usage and cost governance evolved for GitHub Copilot,
Microsoft 365 Copilot Cowork, and Microsoft Work IQ through 2026-07-25. It uses
first-party GitHub and Microsoft sources exclusively.

These products are examples, not additional implementation targets for this
repository. Their histories help separate durable governance concepts from
product-specific meters, prices, and administrative interfaces.

## GitHub Copilot

GitHub Copilot moved through three distinct commercial models: fixed
subscriptions, subscriptions with premium-request allowances, and subscriptions
with token-priced GitHub AI Credits
([fixed subscriptions](https://github.blog/changelog/2022-12-07-github-copilot-is-now-available-for-invoiced-github-enterprise-customers/),
[premium requests](https://github.blog/news-insights/product-news/github-copilot-agent-mode-activated/),
[AI Credits](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/)).

### Fixed subscriptions

- On 2022-06-21, GitHub made Copilot generally available to individuals for
  $10 per month or $100 per year. Verified students and maintainers of popular
  open-source projects could use it without charge
  ([GitHub changelog](https://github.blog/changelog/2022-06-21-github-copilot-is-now-available-to-individual-developers/)).
- On 2022-12-07, GitHub introduced Copilot for Business for invoiced enterprise
  customers at $19 per user per month, adding centralized license, policy, and
  privacy controls
  ([GitHub changelog](https://github.blog/changelog/2022-12-07-github-copilot-is-now-available-for-invoiced-github-enterprise-customers/)).
- On 2024-02-27, Copilot Enterprise became generally available at $39 per user
  per month, adding organization-codebase knowledge and deeper GitHub.com
  integration
  ([GitHub announcement](https://github.blog/news-insights/product-news/github-copilot-enterprise-is-now-generally-available/)).

The governing entitlement in this period was primarily the assigned seat.
Organizations controlled who received a license and which features or policies
applied, while the public pricing model remained a predictable per-user charge
([GitHub Business launch](https://github.blog/changelog/2022-12-07-github-copilot-is-now-available-for-invoiced-github-enterprise-customers/),
[GitHub Enterprise launch](https://github.blog/news-insights/product-news/github-copilot-enterprise-is-now-generally-available/)).

### Enterprise cost allocation

On 2024-09-24, GitHub began moving enterprise customers to an enhanced billing
platform with cost centers, spend reporting by organization, repository,
product, SKU, and cost center, and configurable budgets and alerts. Existing
"spending limits" were migrated and renamed "budgets"
([GitHub changelog](https://github.blog/changelog/2024-09-24-enhanced-billing-platform-for-enterprises/)).

This introduced a financial allocation layer separate from Copilot seat
assignment
([GitHub changelog](https://github.blog/changelog/2024-09-24-enhanced-billing-platform-for-enterprises/)).

### Premium requests

On 2025-04-04, GitHub introduced premium requests for paid Copilot plans.
Copilot Business included 300 premium requests per user per month, Copilot
Enterprise included 1,000, and additional premium requests started at $0.04.
Different models consumed different numbers of premium requests, while paid
plans retained unlimited access to designated included models, subject to rate
limits
([GitHub announcement](https://github.blog/news-insights/product-news/github-copilot-agent-mode-activated/)).

GitHub began enforcing those monthly allowances on 2025-06-18. Allowances reset
on the first day of each month, additional usage required an account spending
limit, and the initial additional-usage limit was $0
([GitHub changelog](https://github.blog/changelog/2025-06-18-update-to-github-copilot-consumptive-billing-experience/)).

This model treated an interaction as a weighted request rather than measuring
its underlying token consumption directly. Allowances were assigned per user
and did not form a shared enterprise pool
([premium-request announcement](https://github.blog/news-insights/product-news/github-copilot-agent-mode-activated/),
[AI-credit transition](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/)).

### GitHub AI Credits

On 2026-04-27, GitHub announced that premium request units would be replaced on
2026-06-01 by GitHub AI Credits calculated from input, output, and cached token
consumption using each model's published API rates. GitHub kept the existing
monthly seat prices, kept code completions and next-edit suggestions outside
AI-credit billing, and introduced pooled included usage for Business and
Enterprise customers
([GitHub announcement](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/)).

Usage-based billing became active on 2026-06-01. GitHub also made user-level
budgets generally available and began charging Copilot code review for GitHub
Actions minutes in addition to AI Credits
([GitHub changelog](https://github.blog/changelog/2026-06-01-updates-to-github-copilot-billing-and-plans/)).

Under the current model:

- One GitHub AI Credit equals $0.01, and each Business or Enterprise seat
  contributes included credits to a shared billing-entity pool
  ([GitHub documentation](https://docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises)).
- User-level budgets cap an individual's included and metered consumption and
  always impose a hard stop. Cost-center, organization, and enterprise budgets
  primarily govern metered charges after the shared pool is exhausted
  ([GitHub documentation](https://docs.github.com/en/copilot/concepts/billing/budgets-for-usage-based-billing)).
- Cost centers can contain users, enterprise teams, organizations, or
  repositories. AI-credit usage is attributed first to the user who triggered
  it, or to the organization that granted the user's Copilot license when the
  user has no direct cost-center assignment
  ([GitHub documentation](https://docs.github.com/en/billing/reference/cost-center-allocation)).
- Business and Enterprise users can see their own consumption for the current
  billing period. When a user-level budget applies, the user sees consumption
  against that budget
  ([GitHub documentation](https://docs.github.com/en/copilot/how-tos/manage-and-track-spending/monitor-ai-usage)).

GitHub therefore evolved from a seat-only entitlement, to a per-user weighted
request allowance, and then to a pooled token-priced credit system with
individual and organizational controls
([GitHub Business launch](https://github.blog/changelog/2022-12-07-github-copilot-is-now-available-for-invoiced-github-enterprise-customers/),
[premium requests](https://github.blog/news-insights/product-news/github-copilot-agent-mode-activated/),
[current budgets](https://docs.github.com/en/copilot/concepts/billing/budgets-for-usage-based-billing)).

## Microsoft 365 Copilot Cowork

Cowork moved from a license-gated preview to a model in which a Microsoft 365
Copilot license enables access and Cowork tasks incur separate usage charges
([Research Preview](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/09/copilot-cowork-a-new-way-of-getting-work-done/),
[general availability](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/)).

### Preview

Microsoft announced Cowork on 2026-03-09 as a Research Preview available to a
limited set of customers
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/09/copilot-cowork-a-new-way-of-getting-work-done/)).

On 2026-03-30, Microsoft made Cowork available through the Frontier program for
early access
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/30/copilot-cowork-now-available-in-frontier/)).

Neither preview announcement published a separate Cowork consumption rate
([Research Preview](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/09/copilot-cowork-a-new-way-of-getting-work-done/),
[Frontier availability](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/30/copilot-cowork-now-available-in-frontier/)).
This document therefore makes no claim about the monetary price of preview
usage.

### General availability and Copilot Credits

On 2026-06-16, Microsoft made Cowork generally available worldwide. Microsoft
stated that Cowork requires a Microsoft 365 Copilot User Subscription License
and that Cowork tasks are then billed separately through usage-based Copilot
Credits
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/)).

Microsoft calculates each task's credit consumption from model use, context
retrieval, tool calls, and runtime. The same announcement set the pay-as-you-go
price at $0.01 per Copilot Credit and described prepaid P3 commitments as an
alternative funding method
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/#pricing-model)).

The GA model added:

- tenant, security-group, and per-user spending limits;
- configurable alerts;
- user-initiated requests for access or additional credits;
- tenant, group, user, and feature reporting; and
- task-level credit visibility for the user
  ([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/#cost-management)).

Current spending policies can select users or Entra security groups, an overall
monthly credit limit, an optional per-user monthly limit, allowed services, and
a billing method. Policies can use prepaid capacity, a Copilot Credit
Pre-Purchase Plan, or an Azure subscription for pay-as-you-go charges
([Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-manage-copilot-credits)).

When several policies cover the same user and service, Microsoft selects one
policy rather than combining them. Selection prefers the highest per-user
limit, then the largest overall policy limit, then the most recently created
policy
([Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-manage-copilot-credits#scope-user-and-group)).

Current Cowork governance documentation also distinguishes the GA system from
the preview administration model: Cowork is now described as an agentic system,
and the preview agent-based access control is no longer used to manage user
access
([Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/copilot/cowork/cowork-admin-governance)).

Cowork therefore evolved from preview access controlled through product and
Frontier enrollment to an identity-aware credit system with tenant, group, and
individual spending policies
([Frontier availability](https://www.microsoft.com/en-us/microsoft-365/blog/2026/03/30/copilot-cowork-now-available-in-frontier/),
[current spending policies](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-manage-copilot-credits)).

## Microsoft Work IQ

Work IQ evolved from license-gated Microsoft 365 Copilot APIs into a broader
workplace-intelligence platform with consumption-priced APIs
([Build 2025 APIs](https://devblogs.microsoft.com/microsoft365dev/microsoft-365-copilot-apis/),
[Work IQ introduction](https://www.microsoft.com/en-us/microsoft-365/blog/2025/11/18/microsoft-ignite-2025-copilot-and-agents-built-to-power-the-frontier-firm/#microsoft-365-copilot-with-work-iq-ai-built-for-work),
[current access model](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/#access-and-pricing)).

### Microsoft 365 Copilot APIs

At Build 2025, Microsoft introduced the first Microsoft 365 Copilot APIs,
including interaction export, change notifications, meeting insights,
retrieval, and chat capabilities. The launch guidance required each API user to
have a Microsoft 365 Copilot license
([Microsoft developer announcement](https://devblogs.microsoft.com/microsoft365dev/microsoft-365-copilot-apis/)).

At Ignite on 2025-11-18, Microsoft introduced Work IQ as the intelligence layer
behind Microsoft 365 Copilot and agents. Microsoft stated that custom agents
could use Work IQ through Copilot Studio or APIs with either a Microsoft 365
Copilot license or consumption billing
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2025/11/18/microsoft-ignite-2025-copilot-and-agents-built-to-power-the-frontier-firm/#microsoft-365-copilot-with-work-iq-ai-built-for-work)).

Microsoft continued to publish Microsoft 365 Copilot APIs as a distinct API
family after introducing the Work IQ name. For example, the November 2025
update separately described the Retrieval API as generally available and the
Chat and Search APIs as public previews
([Microsoft developer announcement](https://devblogs.microsoft.com/microsoft365dev/microsoft-365-copilot-apis-whats-new-and-whats-next/)).

### Work IQ API pricing

On 2026-06-02, Microsoft announced that Work IQ APIs would become generally
available on 2026-06-16. The announcement introduced consumption pricing in
Copilot Credits, with fixed pricing for Tools and variable pricing for Chat and
Context, and introduced the Microsoft 365 Cost Management dashboard for
tenant, group, and user spending limits
([Microsoft announcement](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/02/announcing-the-new-work-iq-apis/#work-iq-apis-pricing)).

Microsoft's GA licensing guidance prices the Work IQ Tool API at 0.1 Copilot
Credits per API call. Chat and Context consumption remains variable, and
Microsoft directs customers to its Copilot Credit Guide for current rates
([Microsoft licensing guidance](https://www.microsoft.com/en-us/licensing/news/work-iq-general-availability)).

The current Work IQ documentation states that API access is independent of a
Microsoft 365 Copilot license and is available through usage-based billing.
Custom and third-party agent use remains billable even when the user has a
Microsoft 365 Copilot license
([Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/#access-and-pricing)).

Work IQ uses the same Copilot Credit Cost Management system as Cowork. Microsoft
documents Cowork and Work IQ API as the first services governed through this
experience
([Microsoft documentation](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-overview-copilot-credits#services-managed-by-usage-based-billing)).

Work IQ therefore evolved from APIs whose access was tied to a per-user Copilot
license toward a delegated, user-scoped API platform whose custom application
usage is charged separately and governed through tenant, group, user, and
service policies
([initial API licensing](https://devblogs.microsoft.com/microsoft365dev/microsoft-365-copilot-apis/),
[current access and pricing](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/#access-and-pricing),
[API authorization model](https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/work-iq/api-overview#authorization)).

## Cross-product lessons

The following is a retrospective synthesis of the cited public announcements,
not a prediction or statement of any non-public product roadmap.

The product histories show a recurring progression:

1. **License-gated access.** A seat or add-on initially determines who can use
   the capability, as shown by early GitHub Copilot subscriptions and the first
   Microsoft 365 Copilot APIs
   ([GitHub](https://github.blog/changelog/2022-12-07-github-copilot-is-now-available-for-invoiced-github-enterprise-customers/),
   [Microsoft](https://devblogs.microsoft.com/microsoft365dev/microsoft-365-copilot-apis/)).
2. **A variable usage unit.** Providers introduce weighted requests or credits
   when model and agent workloads vary materially in cost
   ([GitHub premium requests](https://github.blog/news-insights/product-news/github-copilot-agent-mode-activated/),
   [Cowork Copilot Credits](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/#pricing-model)).
3. **Normalized provider credits.** Providers transform one or more lower-level
   measurements into a product-specific billing unit
   ([GitHub AI Credits](https://docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises),
   [Microsoft Copilot Credits](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-overview-copilot-credits)).
4. **Hierarchical governance.** User, group or cost-center, organization, and
   tenant or enterprise controls are added as usage becomes variable
   ([GitHub budgets](https://docs.github.com/en/copilot/concepts/billing/budgets-for-usage-based-billing),
   [Microsoft spending policies](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-manage-copilot-credits)).
5. **Multiple reporting views.** Providers expose different personal and
   administrative views of usage and spending
   ([GitHub personal usage](https://docs.github.com/en/copilot/how-tos/manage-and-track-spending/monitor-ai-usage),
   [GitHub company spending](https://docs.github.com/en/copilot/how-tos/manage-and-track-spending/manage-company-spending),
   [Microsoft Cost Management](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-manage-copilot-credits#monitoring-spending-of-copilot-credits)).

These similarities do not make the products' credits interchangeable. GitHub AI
Credits and Microsoft Copilot Credits have different pricing transformations,
funding rules, policy precedence, and product coverage
([GitHub](https://docs.github.com/en/copilot/concepts/billing/usage-based-billing-for-organizations-and-enterprises),
[Microsoft](https://learn.microsoft.com/en-us/microsoft-365/copilot/usage-based-billing-overview-copilot-credits)).

For product-neutral architecture, document the following separately:

- authenticated actor;
- entitlement or license gate;
- consumption unit and pricing transformation;
- individual, group, organization, and provider scopes;
- included, prepaid, and pay-as-you-go funding;
- alert-only budgets versus enforced limits;
- policy precedence and fallback behavior;
- user, administrator, billing, and operational visibility; and
- reset, rollover, and lifecycle rules.

The specific product examples above should remain date-stamped because their
meters and administrative models have already changed substantially over short
periods
([GitHub premium-request transition](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/),
[Cowork general availability](https://www.microsoft.com/en-us/microsoft-365/blog/2026/06/16/copilot-cowork-is-now-generally-available/),
[Work IQ general availability](https://www.microsoft.com/en-us/licensing/news/work-iq-general-availability)).
