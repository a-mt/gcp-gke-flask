# Flask app on GKE

Base: [gcp-app-engine-flask](https://github.com/a-mt/gcp-app-engine-flask)

## Launch locally

* Start

  ```
  docker-compose up
  ```

* Go to localhost:8080

## Setup your GCP project

* Create a new project on GCP
* Activate a Billing account
* Activate the following APIs:

  - Cloud Deployment Manager V2 API
  - Kubernetes Engine API
  - Compute Engine API
  - Artifact Registry API

## Setup GKE + Docker registry

* [INFRA_GOOGLE_CONSOLE](./INFRA_GOOGLE_CONSOLE.md)
