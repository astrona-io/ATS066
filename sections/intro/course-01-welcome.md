# Welcome To The Course

This course prepares you for the Related Practices domain of the Certified GitOps Associate (CGOA) exam. The domain is worth 16% of the published curriculum. The course is independently written practice material and does not simulate the exam.

## Who the course is for

The course is for people who deliver software to Kubernetes and want to understand the practices around GitOps: configuration as code, infrastructure as code, DevOps and DevSecOps, and continuous integration and delivery. You need basic knowledge of Pods, Deployments, namespaces and the `kubectl` command. You do not need prior knowledge of OpenTofu or Kustomize.

## What you can do at the end

After the course you can calculate and repair a rolling update, declare the configuration of a service as versioned input with Kustomize, and describe infrastructure with OpenTofu and read its plan. You can detect drift and import objects that someone made by hand, give a team limited access with quotas and Pod Security, record a release by its image digest, and promote and roll back a release.

## The words the course uses

Configuration as code means that the settings of a system are stored in files under version control. Infrastructure as code means that the files describe the resources themselves, and a tool such as OpenTofu makes the resources match. Drift is a difference between the files and the real resources. A pipeline is a series of automatic steps that builds, checks and releases a change. Each page defines a term again the first time it appears.

## The example application

The examples use a small application. The `scout` Deployment in the `starfleet` namespace runs podinfo, a small HTTP server on port 9898. The `probe` Deployment runs an HTTP test server. The `shuttle` pod in `starfleet` and the `drifter` pod in `outpost` are client pods with `curl`. The names are only labels for the examples and carry no technical meaning.

## How the course is laid out

The course has four sections, one for each exam objective. A section has two modules. A module has a landing page, reading parts, a graded lab and a summary. Each module has a playground, which is a private cluster for the hands-on steps. Each section ends with a capstone lab and a knowledge check, and the course ends with a final knowledge check.

Read each part in order. Run the commands in the playground as you read. Then solve the lab task in its own environment before you open the solution.
