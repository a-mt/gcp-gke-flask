# Setup using Terraform

## Set up Terraform Cloud

* Create a [workspace on Terraform Cloud](https://app.terraform.io/)

* Workspace > Variables > Add variable

  ```
  gcp_credentials = "..."
  gcp_project_id = "test-gke-419405"
  gcp_project_name = "Test GKE"
  gcp_project_number = "353914959645"
  ```

## Provision the infra

* Prerequisite: install terraform

  ``` bash
  terraform version
  ```

* Login to Terraform Cloud

  ``` bash
  terraform login
  ```

* Apply terraform  
  Note: creating a Kubernetes cluster for the first time takes about 30 min.  
  If you update the node_config, the node pool gets recreated, which takes about 5 min total

  ``` bash
  cd infra

  terraform init
  terraform plan
  terraform plan
  ```

## Connect to the Kubernetes cluster

* Retrieve the credentials to connect to the cluster

  ``` bash
  $ terraform output -raw gke_kubeconfig > kubeconfig
  $ cat kubeconfig
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority-data:
  ...
  ```

  To use as default:

  ``` bash
  $ cp ~/.kube/config ~/.kube/config.bak.$(date "+%s")
  $ echo Saved to !$
  $ cp kubeconfig ~/.kube/config
  ```

* Check that you have access to the cluster

  ``` bash
  $ kubectl get nodes
  NAME                                        STATUS   ROLES    AGE   VERSION
  gke-test-gke-2-default-pool-88f475c2-n05d   Ready    <none>   21m   v1.27.8-gke.1067004
  gke-test-gke-2-default-pool-88f475c2-r8ph   Ready    <none>   21m   v1.27.8-gke.1067004
  ```

## Authenticate Docker to the artifact registry

``` bash
$ DOCKER_HOSTNAME=$(terraform output -raw docker_registry_hostname)
$ echo $DOCKER_HOSTNAME
us-west1-docker.pkg.dev

$ DOCKER_AUTH=$(terraform output -raw docker_registry_write_json_key)
$ echo $DOCKER_AUTH
ewogICJ0eX...

$ GOOGLE_APPLICATION_CREDENTIALS=$(echo $DOCKER_AUTH | base64 -d | tr -s '\n' ' ')
$ echo $GOOGLE_APPLICATION_CREDENTIALS
{ "type": "service_account", "project_id": "test-gke-419405", "private_key_id": ...

$ echo "$GOOGLE_APPLICATION_CREDENTIALS" | docker login -u _json_key --password-stdin https://$DOCKER_HOSTNAME
WARNING! Your password will be stored unencrypted in /home/aurelie/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

## Push an image to the registry

* Build the image

  ``` bash
  $ docker-compose -f docker-compose.full.yml build
  ```

* Tag the image & push it to the registry

  ``` bash
  $ DOCKER_REPOSITORY=$(terraform output -raw docker_registry_repository_url)
  $ echo $DOCKER_REPOSITORY
  us-west1-docker.pkg.dev/test-gke-419405/test-gke-repo-2

  $ docker tag gcp-gke-flask-web-full:latest ${DOCKER_REPOSITORY}/flask:v1
  $ docker push !$
  ```

## Create a K8s deployment

[Same as gcloud setup](SETUP_GCLOUD.md#create-a-k8s-deployment)  
(except firewall rules are already created)