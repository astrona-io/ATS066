# Curriculum Coverage

Exam: Certified GitOps Associate (CGOA). Domain: Related Practices (16%).

The [official objectives](https://training.linuxfoundation.org/certification/certified-gitops-associate-cgoa/) were checked on 2026-10-11. Teaching structure is independently authored and does not add official requirements.

| Section | Official objective | Modules | Capstone lab | Quiz |
| --- | --- | --- | --- | --- |
| 010 | Configuration as Code (CaC) | 2 | Deliver A Configuration Change Safely | 12 questions |
| 020 | Infrastructure as Code (IaC) | 2 | Bring A Hand-Made Depot Under OpenTofu | 6 questions |
| 030 | DevOps and DevSecOps | 2 | Bring A Bay To A Safe Supported State | 6 questions |
| 040 | CI and CD | 2 | Recover Production And Promote A Release With Evidence | 6 questions |

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

Each module has a playground and a graded lab. The final domain quiz has 16 questions, four for each section.

AUTHORING.yaml records measurable goals and adaptation sources. Every objective retains its section ID. All technical readings remain draft. Question banks are listed in assessments/index.yaml and as quiz entries in astrona.yaml. The labs and playgrounds have been checked statically only; no runtime execution is claimed.
