# AI value realization and cost attribution

AI cost governance is ultimately a capital-allocation problem, not merely a
token-management problem. An organization should compare the risk-adjusted
value expected from an AI investment with its total cost and with the return
available from the next-best use of the same resources.

Usage is an input, not value. Tokens, requests, credits, and currency describe
what an AI capability consumes. They do not establish whether that consumption
produced a worthwhile outcome.

## Start with the value thesis

Before selecting quotas or reporting dimensions, define how the investment is
expected to create value:

- the outcome the organization wants to change;
- the mechanism by which the AI capability should affect that outcome;
- the people, process, product, or business unit expected to benefit;
- the accountable owner and funding source;
- the period over which benefits should materialize; and
- the counterfactual or next-best alternative against which results will be
  assessed.

The relevant financial measure depends on the decision. A discrete investment
may justify an NPV analysis, while an operating service may be better assessed
through incremental contribution, cost avoidance, unit economics, or
value-for-money. In each case, the comparison should include total lifecycle
cost rather than model consumption alone.

## Match attribution to the expected source of value

The appropriate unit of accountability should follow the investment's value
thesis.

| Expected value | Useful outcome measures | Primary cost attribution |
| --- | --- | --- |
| Individual productivity | Time saved, output quality, additional capacity, task completion | Authenticated user, with roll-up to team and funding owner |
| Team or business process | Throughput, cycle time, rework, reliability, service quality | Agent, application, APIM subscription, process, or team |
| Customer experience | Satisfaction, response time, retention, conversion, resolution rate | Customer journey, product, channel, or application |
| Business performance | Incremental revenue, margin, operating cost, risk reduction, strategic option value | Product, program, business unit, or enterprise portfolio |

Time saved is not automatically economic value. It becomes valuable when the
released capacity is converted into higher output, shorter lead times, better
quality, lower cost, improved customer outcomes, or another measurable benefit.

Likewise, value created at the process or business level should not be forced
into an individual ROI model merely because an individual initiated the AI
request. The measurement level should reflect where the benefit is expected to
materialize.

## Preserve multiple attribution dimensions

A single quota key cannot represent every governance concern. Each request
should preserve the dimensions needed to answer different questions:

- **Human actor:** Who initiated or benefited from the activity?
- **Workload identity:** Which agent, application, API, or automation consumed
  the resource?
- **Organizational owner:** Which team, department, product, or process is
  accountable for the workload?
- **Funding source:** Which budget, cost center, subscription, or shared pool
  pays for it?
- **Value beneficiary:** Where is the expected operational or economic benefit?

These dimensions may not be the same. A person can use a shared application,
the application can consume through a department-level APIM subscription, a
central platform team can fund the infrastructure, and a separate business unit
can receive the benefit.

Maintaining these dimensions separately allows costs and outcomes to be rolled
up without treating one technical identifier as the universal unit of
accountability.

## Align controls, reporting, and decisions

The governance scope should match the decision being made:

- Apply spending limits where budget authority resides.
- Enforce operational quotas where scarce capacity must be protected.
- Attribute usage to the actor and workload at the finest practical level.
- Measure outcomes where benefits are expected to materialize.
- Evaluate ROI or NPV at a scope and time horizon that includes both the costs
  and benefits of the decision.

This permits different but compatible controls. For example, an organization
can enforce a department-level quota through a shared APIM subscription while
retaining user identity for personal usage reporting and attributing the
resulting business outcomes to the application or process.

## Use a hierarchy of evidence

Evaluation should connect consumption to progressively more meaningful
evidence:

1. **Inputs:** tokens, requests, credits, infrastructure, labor, and currency.
2. **Activity:** users served, tasks attempted, workflows executed, or
   transactions processed.
3. **Operational outcomes:** time saved, throughput, lead time, quality,
   reliability, or customer satisfaction.
4. **Economic outcomes:** revenue, margin, cost avoided, losses prevented, or
   risk-adjusted NPV.

Input and activity metrics are usually available sooner, but they should not be
presented as proof of value. The strongest investment decisions connect them to
operational and economic outcomes and compare those outcomes with a credible
alternative.

## Avoid misusing individual attribution

When value is expected at the individual level, user-level cost attribution can
help explain adoption, concentration of spend, and differences in unit
economics. It should not be treated as a standalone measure of employee
performance.

High usage may reflect valuable work, inefficient workflows, experimentation,
or the nature of a person's role. Low usage may indicate poor product fit,
limited access, or work that does not benefit from the capability. Individual
reporting should therefore be proportionate, transparent, and interpreted
alongside role, outcome, privacy, and organizational context.

## Guiding principle

> Align cost attribution, outcome measurement, and decision rights with the
> level at which value is expected to be created.
