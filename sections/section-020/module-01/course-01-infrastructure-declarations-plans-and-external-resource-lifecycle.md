---
draft: true
exam_objectives:
- Infrastructure as Code (IaC)
---
# Infrastructure Declarations, Plans And External Resource Lifecycle

Infrastructure as code manages infrastructure through code or declarative inputs rather than undocumented manual interaction. It can describe networks, databases, identity policies and other external resources. The implementation uses provider APIs to create and change those resources. This supports review and repeatability, while the actual lifecycle and safety depend on the tool's contracts and the organization's policy.

Infrastructure and application configuration overlap but are not identical scopes. A database server's capacity and network access can be infrastructure intent. A service's connection reference and runtime settings can be application configuration. The boundary should identify who owns each input and how dependencies are communicated. Otherwise two teams can make incompatible assumptions about the same resource.

Some IaC tools use provider state to associate declared objects with actual external resources. That state can contain identifiers and sensitive values. It has integrity, access and coordination requirements of its own. Losing or corrupting it can make future planning ambiguous. Treating it as a harmless disposable cache can create serious operational uncertainty.

Plans describe proposed changes according to the implementation's current view and inputs. They can reveal creation, update and destruction before application. Review should assess the business meaning of those changes, especially replacement of durable resources. A plan is not a guarantee that external conditions remain unchanged until execution, and it is not a backup of the resource's data.

Consider a database capacity change that a provider models as replacement rather than in-place modification. The desired value looks small in the source diff, but the plan can propose removing one resource and creating another. Data migration and downtime then become part of the decision. A reviewer needs the provider lifecycle semantics, not only the changed number.

Importing an existing resource introduces another contract. The tool must associate the external identity with the intended declaration and ownership. An import does not prove that the generated or written configuration matches every relevant live setting. Subsequent planning can expose differences. The team should avoid accidentally adopting a resource that another controller still owns.

Sensitive inputs need protected delivery. Versioning an encrypted reference or a secret-store relationship differs from committing plaintext credentials. Provider state can also reveal values not visible in the original source. Access policy should therefore cover both desired input and implementation state. The tool's use of code does not automatically make its operational files safe to publish.

IaC maps to GitOps only when the actual system satisfies the relevant principles. A versioned declarative input meets useful properties. A CI job that applies it once and exits may not independently retrieve state or reconcile later drift. A controller that pulls identified versions and continuously manages external resources can support a GitOps model. The tool name alone does not decide this.

Failure handling should distinguish invalid intent, provider authentication, external capacity and lifecycle conflict. Retrying a denied cloud operation will not repair an incorrect role. Repeating a non-idempotent provisioning request without stable identity can create duplicates. Controlled observation and useful status are essential when infrastructure changes have real cost or persistence.

## Common pitfalls

> [!WARNING]
> IaC is not automatically GitOps. Protect provider state and review replacement or destruction semantics. A small source diff can have a large infrastructure consequence, and a plan does not restore data or eliminate changes in external conditions.
