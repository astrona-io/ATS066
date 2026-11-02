---
draft: true
exam_objectives:
- Configuration as Code (CaC)
---
# Summary

Rolling updates replace a changed Pod template under configured availability and surge constraints. Percentage rounding and readiness conditions affect the resulting replacement sequence.

Progress depends on capacity, image preparation, startup and useful health checks. A deadline condition reports failed progress without proving a rollback occurred. External configuration and data remain outside the complete template-history contract.
