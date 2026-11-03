---
draft: true
exam_objectives:
- DevOps and DevSecOps
---
# The Software Supply Chain And Its Attack Points

Most of the code in a modern service was not written by the team that runs it. It comes from open source libraries, base images, build tools and shared actions. Every one of these is an input that a team trusts. A supply chain attack changes one of the inputs so that a trusted path carries harmful code into production. This part lists the links of the chain and the four kinds of evidence that defend them.

## The links and their risks

The chain starts with source code in a repository. An attacker with a stolen token can push a change, so branch protection and reviews matter. Dependencies come next. A package with a name close to a popular one (typosquatting) or an internal package name registered on a public registry (dependency confusion) can pull in harmful code. The build runs on a runner with access to secrets and to the registry, so a compromised build step can change the artifact after the tests passed. The registry stores images and can be written to by anyone with push rights. At deployment, the cluster pulls an image by a name, and a name can point to different content later.

## Four kinds of evidence

Each check answers a different question, and none of them answers all of them.

- A **vulnerability scan** compares the packages in an image with a database of known vulnerabilities, listed with Common Vulnerabilities and Exposures (CVE) identifiers. It finds known problems and says nothing about unknown ones. Tools: Trivy, Grype.
- An **SBOM** lists every component and version in an artifact, in a standard format such as SPDX or CycloneDX. It lets you answer "do we run the affected library?" within minutes when a new vulnerability appears. Tool: Syft.
- **Provenance** is a signed statement of how the artifact was built: from which source commit, by which builder, with which inputs. The Supply-chain Levels for Software Artifacts (SLSA) framework defines levels of build integrity that a pipeline can reach.
- A **signature** proves who published an artifact and that it was not changed afterwards. Sigstore, with the `cosign` tool, signs images and stores the signature in the registry next to the image. Keyless signing ties a signature to an identity such as a pipeline run, so the team need not keep a long-lived key.

## Take an inventory of your cluster

The first practical step is to know what runs. List every distinct image in the cluster:

<!-- astrona:playground:renew -->

```sh
kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' | sort -u
```

The output has one image reference per line. The list contains the system images of the cluster and the application images. When a vulnerability in a base image is announced, this list is the starting point for the question of which workloads are affected. Teams automate the same query and store the result next to the SBOMs.

Look at the references themselves. A name such as `registry.k8s.io/pause:3.10` has a registry, a path and a tag. The tag is a label that the publisher can move. Count how many references in your list use `latest` or no tag at all, because those are the references whose content you cannot predict.

## What no single check covers

A scan of an image at build time is old by the time the image runs, since new vulnerabilities are published every day. A signature proves origin and not safety: a signed image can still contain a vulnerable library. An SBOM is a list and not a judgement. The checks work as layers, and the next parts add two of them that belong to the cluster: a naming rule that fixes the content of an image and an admission rule that enforces it.

## Common pitfalls

> [!WARNING]
> - A clean scan result does not mean the image is safe. It means no known vulnerability matched at the time of the scan.
> - A signature checked only in the pipeline does not stop someone from deploying an unsigned image by hand. The cluster must check too.
> - Base images age. Rebuild images regularly, even when the application code is unchanged.
> - Do not give build runners more rights than the build needs, and never keep long-lived registry credentials in the repository.
