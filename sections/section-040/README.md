---
draft: true
exam_objectives:
  - CI and CD
---
# Section 040: CI and CD

This section teaches you what a build pipeline proves and what it does not, how a release is identified, and how one artifact moves through environments. You will write a check, record a release with its image digest, verify the record against the running pods, roll back a failed release, promote the same artifact and compare push-based with pull-based delivery.

**Exam objective covered:** CI and CD

---

## What You Will Master

- Name what continuous integration, continuous delivery and continuous deployment each add.
- Write a check script and say what a passing check proves and does not prove.
- Identify a release by its image digest and compare it with the `imageID` that the pods report.
- Record a change cause and read a rollout history.
- Promote one artifact through environments and keep the settings of each environment separate.
- Gate a release with `kubectl rollout status --timeout`, roll back with `kubectl rollout undo` and say what a rollback restores.
- Explain where the cluster credentials live in a push model and in a pull model.
- Compare recreate, rolling, blue-green and canary deployments, and say how CI and a GitOps agent share the work.

---

## The Learning Path

### 1. Build And Release Pipelines
*   **Module Reader:** **[Module 1: Build And Release Pipelines](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-01/playground` - kind cluster. The Starfleet workloads run. There is no CI server; your machine plays the pipeline.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/playground
    ```
*   **Lab:** `sections/section-040/module-01/labs/lab-01` (UNTESTED) - Release an artifact with verifiable evidence.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Promotion Delivery And Rollback
*   **Module Reader:** **[Module 2: Promotion Delivery And Rollback](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-02/playground` - kind cluster. Two environments, `staging` and `production`, run the same image with their own settings.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/playground
    ```
*   **Lab:** `sections/section-040/module-02/labs/lab-01` (UNTESTED) - Roll back a failed release and promote correctly.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-02/labs/lab-01
    astrona submit -c .
    ```

### 3. CI/CD Concepts, Pipelines And Deployment Strategies
*   **Module Reader:** **[Module 3: CI/CD Concepts, Pipelines And Deployment Strategies](./module-03/course.md)**
*   **Hands-on Playground:** `sections/section-040/module-03/playground` - kind cluster. The `launch` namespace runs `scout-blue` behind a Service that selects `version: blue`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-03/playground
    ```
*   **Lab:** `sections/section-040/module-03/labs/lab-01` (UNTESTED) - Deploy green, switch the Service selector and keep blue for rollback.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/module-03/labs/lab-01
    astrona submit -c .
    ```
*   **Module quiz:** 10 questions in `sections/section-040/module-03/quiz.yaml`. The pass score is 70 percent.

### Section Capstone Challenge
*   **Comprehensive Challenge:** Recover Production And Promote A Release With Evidence - `sections/section-040/capstone/labs/lab-01` (UNTESTED)
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS066.git -c sections/section-040/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** In the namespaces `preview` and `live`, recover `live` from a bad release, promote the release that passed in `preview` with the same image digest, write the release record and give the pipeline a limited identity. The grader checks live cluster state.

### Knowledge Check
*   **Quiz:** 6 questions in `sections/section-040/quiz.yaml`. The pass score is 70 percent.
