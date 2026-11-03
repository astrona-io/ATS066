---
draft: true
exam_objectives:
  - Configuration as Code (CaC)
---
# Section 010: Configuration as Code (CaC)

This section teaches you to deliver a change to a running service without losing capacity. You will calculate the limits of a rolling update, repair a stalled rollout, roll back, and declare the configuration of a service as versioned input with Kustomize so that a change reaches every pod.

**Exam objective covered:** Configuration as Code (CaC)

---

## What You Will Master

- Name the changes that create a Deployment revision and read a rollout with `kubectl rollout`.
- Calculate the limits of `maxSurge` and `maxUnavailable`, including their rounding.
- Explain what `minReadySeconds`, readiness probes and `progressDeadlineSeconds` add, and why a stalled rollout is reported and not undone.
- Roll back with `kubectl rollout undo` and verify the result.
- Explain how a ConfigMap or a Secret reaches a pod, and why environment variables, volume files and `subPath` mounts behave differently.
- Build a Kustomize base and overlay with a generated ConfigMap, preview with `kubectl diff -k` and find drift that an apply does not remove.

---

## The Learning Path

### 1. Rolling Updates And Availability
*   **Module Reader:** **[Module 1: Rolling Updates And Availability](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-01/playground` - kind cluster. The Starfleet workloads run and the `scout` Deployment has four replicas and a readiness probe on `/readyz`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/playground
    ```
*   **Lab:** `sections/section-010/module-01/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Configuration As Versioned Input
*   **Module Reader:** **[Module 2: Configuration As Versioned Input](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-010/module-02/playground` - kind cluster. The Starfleet workloads run and `scout` has two replicas. No ConfigMap, Secret or Kustomize file exists yet.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/playground
    ```
*   **Lab:** `sections/section-010/module-02/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Deliver A Configuration Change Safely - `sections/section-010/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-010/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** In the namespace `outpost`, deliver the new message `scout v2` through a Kustomize overlay and a generated ConfigMap, keep capacity with `maxUnavailable: 0`, a readiness probe and `minReadySeconds`, keep the API key in its Secret, remove the old ConfigMap and record the live ConfigMap name and revision in a ConfigMap. The grader checks live cluster state.

### Knowledge Check
*   **Quiz:** 12 questions in `sections/section-010/quiz.yaml`. The pass score is 70 percent.
