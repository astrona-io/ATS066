---
draft: true
exam_objectives:
  - Infrastructure as Code (IaC)
---
# Section 020: Infrastructure as Code (IaC)

This section teaches you to describe infrastructure in OpenTofu files, read a plan before anything changes, and keep the files and the cluster in agreement. You will declare Kubernetes objects, tell an update in place from a replacement, protect a resource with a lifecycle rule, detect drift, import objects that someone made by hand, and place OpenTofu next to GitOps. You need OpenTofu installed on your machine; the playground cluster is reached through your kubeconfig.

**Exam objective covered:** Infrastructure as Code (IaC)

---

## What You Will Master

- Write `terraform`, `provider` and `resource` blocks and run `tofu init`, `tofu plan` and `tofu apply`.
- Read a plan, including `~` updates in place and `-/+` replacements marked `forces replacement`.
- Explain what the state records and why `prevent_destroy` only protects against OpenTofu.
- Detect drift with `tofu plan`, `-detailed-exitcode` and `-refresh-only`.
- Adopt an existing object with an `import` block and prove that it was not recreated.
- Explain how a push-based OpenTofu run differs from a continuous reconciliation agent.
- Explain mutable and immutable infrastructure, declarative and imperative code, and how a CRD and a controller make Kubernetes a control plane.

---

## The Learning Path

### 1. Declarations Plans And Resource Lifecycle
*   **Module Reader:** **[Module 1: Declarations Plans And Resource Lifecycle](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` - kind cluster. The Starfleet workloads run. No OpenTofu file exists; you install OpenTofu on your machine.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/playground
    ```
*   **Lab:** `sections/section-020/module-01/labs/lab-01` (UNTESTED) - Declare a Hangar With OpenTofu.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Drift State And Reconciliation
*   **Module Reader:** **[Module 2: Drift State And Reconciliation](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-02/playground` - kind cluster. The Starfleet workloads run. No OpenTofu file or state exists.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/playground
    ```
*   **Lab:** `sections/section-020/module-02/labs/lab-01` (UNTESTED) - Import hand-made objects and reconcile drift.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-02/labs/lab-01
    astrona submit -c .
    ```

### 3. Infrastructure As Code Concepts, Immutability And Safe Change
*   **Module Reader:** **[Module 3: Infrastructure As Code Concepts, Immutability And Safe Change](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-03/playground` - kind cluster. The Starfleet workloads run and no OpenTofu file exists. You can test immutable fields and a custom resource.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-03/playground
    ```
*   **Lab:** `sections/section-020/module-03/labs/lab-01` (UNTESTED) - Replace a workload whose selector cannot be changed.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/module-03/labs/lab-01
    astrona submit -c .
    ```
*   **Module quiz:** 10 questions in `sections/section-020/module-03/quiz.yaml`. The pass score is 70 percent.

### Section Capstone Challenge
*   **Comprehensive Challenge:** Bring A Hand-Made Depot Under OpenTofu - `sections/section-020/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-020/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** In the namespace `depot`, import the objects that were made by hand without recreating them, remove the drift, and protect the critical resource with a lifecycle rule. The grader checks live cluster state, including that the unique identifiers of the imported objects did not change.

### Knowledge Check
*   **Quiz:** 6 questions in `sections/section-020/quiz.yaml`. The pass score is 70 percent.
