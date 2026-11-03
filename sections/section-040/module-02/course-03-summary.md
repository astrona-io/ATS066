---
draft: true
exam_objectives:
- CI and CD
---
# Summary

A promotion moves one artifact through environments. The same image runs in staging and production, and only the configuration differs. Building again for production produces a new artifact that staging never tested.

Gates stop a release at each step. A static check stops an invalid manifest, `kubectl rollout status` stops a release whose pods are not ready, a smoke test stops a release that starts but does not answer, and an approval stops a release that nobody agreed to. The rollout status command exits with a non-zero code on failure, which is what a pipeline reads.

A rolling update keeps the old pods until new pods are ready, so a failed release degrades capacity and does not take the service down. `kubectl rollout undo` returns the pod template to the previous revision. It does not restore other objects such as ConfigMaps, so configuration should be versioned together with the Deployment.

A push pipeline holds cluster credentials outside the cluster. A pull agent in the cluster reads desired state from a repository, keeps the credentials inside, and corrects drift. Rollback in a pull model is a revert commit.

Key facts:

- Compare the `imageID` of pods in both environments after a promotion.
- `--timeout` on `rollout status` turns a stuck release into a failed gate.
- The rollback creates a new revision with the old template.
- Pull delivery changes where changes are applied, not whether checks are needed.

<!-- astrona:playground:destroy -->
