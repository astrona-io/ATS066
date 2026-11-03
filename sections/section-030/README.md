---
draft: true
exam_objectives:
  - DevOps and DevSecOps
---
# Section 030: DevOps and DevSecOps

This section teaches you to turn shared ownership into objects that a cluster can enforce. You will give a team access that stops at its namespace, set a quota and default limits, read the feedback a refused change gives, enforce the restricted Pod Security level, repair an unsafe workload, and limit what a deployment identity may do and read.

**Exam objective covered:** DevOps and DevSecOps

---

## What You Will Master

- Explain shared ownership and what a platform team offers an application team.
- Give a team a ServiceAccount, a Role and a RoleBinding, and test them with `kubectl auth can-i --as`.
- Set a ResourceQuota and a LimitRange, and find the event that explains a refusal.
- Choose between the Pod Security modes enforce, audit and warn, and read a restricted-level violation.
- Repair a pod specification with a security context, including a numeric `runAsUser`.
- Limit a deployment identity with `resourceNames` and give a container a Secret by reference.
- Explain the four key delivery metrics and blameless reviews, and reject mutable image tags with a ValidatingAdmissionPolicy.

---

## The Learning Path

### 1. Shared Ownership Feedback And Platform Enablement
*   **Module Reader:** **[Module 1: Shared Ownership Feedback And Platform Enablement](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-01/playground` - kind cluster. The Starfleet workloads run. No identity, Role, quota or LimitRange exists yet.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/playground
    ```
*   **Lab:** `sections/section-030/module-01/labs/lab-01` (UNTESTED) - Build a platform contract for an application team.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Security Checks In The Delivery Path
*   **Module Reader:** **[Module 2: Security Checks In The Delivery Path](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-02/playground` - kind cluster. The namespace `dockyard` holds an unsafe `scout` Deployment and a Secret. No Pod Security label is set.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/playground
    ```
*   **Lab:** `sections/section-030/module-02/labs/lab-01` (UNTESTED) - Enforce Pod Security and restrict the deployer.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-02/labs/lab-01
    astrona submit -c .
    ```

### 3. DevOps Principles, Feedback And Measurement
*   **Module Reader:** **[Module 3: DevOps Principles, Feedback And Measurement](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-03/playground` - kind cluster. The Starfleet workloads run without owner labels or runbook annotations, so you can add them and read the rollout history.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-03/playground
    ```
*   **Lab:** `sections/section-030/module-03/labs/lab-01` (UNTESTED) - Add owner labels, runbook annotations and a recorded change cause.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-03/labs/lab-01
    astrona submit -c .
    ```
*   **Module quiz:** 10 questions in `sections/section-030/module-03/quiz.yaml`. The pass score is 70 percent.

### 4. Software Supply Chain Security And Admission Policy
*   **Module Reader:** **[Module 4: Software Supply Chain Security And Admission Policy](./module-04/course.md)**
*   **Hands-on Playground:** `sections/section-030/module-04/playground` - kind cluster. The `dock` namespace runs `scout` on the tag `latest`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-04/playground
    ```
*   **Lab:** `sections/section-030/module-04/labs/lab-01` (UNTESTED) - Write a ValidatingAdmissionPolicy and a binding, label the namespace and repair `scout`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/module-04/labs/lab-01
    astrona submit -c .
    ```
*   **Module quiz:** 10 questions in `sections/section-030/module-04/quiz.yaml`. The pass score is 70 percent.

### Section Capstone Challenge
*   **Comprehensive Challenge:** Bring A Bay To A Safe Supported State - `sections/section-030/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-030/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** In the namespace `bay`, add a quota and default limits, enforce the restricted Pod Security level, repair the `relay` Deployment, restrict the team identity to what it needs and record the result in a ConfigMap. The grader checks live cluster state.

### Knowledge Check
*   **Quiz:** 6 questions in `sections/section-030/quiz.yaml`. The pass score is 70 percent.
