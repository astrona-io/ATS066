# Related Practices (ATS066)

Certified GitOps Associate (CGOA): Related Practices, worth 16% of the official curriculum. This course belongs to ATP013.

The course has four sections and eight modules. Every module has reading parts, a playground (a private kind cluster for free exploration) and a graded lab. Every section has a capstone lab and a knowledge check, and the course ends with a final domain knowledge check. Technical content remains draft, and the labs and playgrounds are built untested: they have only been checked statically.

## Course Outline

| Section / module | Module | Reading parts |
| --- | --- | --- |
| 010 / 01 | Rolling Updates And Availability | Rolling Updates And Health Gates; Calculating Rollout Capacity And Diagnosing Progress; Rollback, History And Verification |
| 010 / 02 | Configuration As Versioned Input | Configuration As Declared Input; How A Configuration Change Reaches Pods; Kustomize Overlays, Diff And Drift |
| 020 / 01 | Declarations, Plans And Resource Lifecycle | Declaring Resources With OpenTofu; Reading Plans, Replacement And Lifecycle Rules |
| 020 / 02 | Drift, State And Reconciliation | State, Drift And Detection; Importing Resources And The GitOps Boundary |
| 030 / 01 | Shared Ownership, Feedback And Platform Enablement | Ownership Boundaries With Namespaces And RBAC; Supported Limits And Actionable Feedback |
| 030 / 02 | Security Checks In The Delivery Path | Pod Security Admission And Security Contexts; Least-Privilege Deployment Identities And Secrets |
| 040 / 01 | Build And Release Pipelines | Source Changes And Build Evidence; Delivery, Deployment And Release Identity |
| 040 / 02 | Promotion, Delivery And Rollback | Promoting One Artifact Through Environments; Gates, Rollback And Pull-Based Delivery |

## Tools

The hands-on steps need `astrona`, a container engine, `kubectl` (which includes Kustomize) and OpenTofu. See the introduction for details.

## Author Review

See [curriculum coverage](CURRICULUM.md), [primary sources](SOURCES.md), [question-bank documentation](ASSESSMENTS.md) and [contribution instructions](CONTRIBUTING.md). No lab or playground run is claimed.
