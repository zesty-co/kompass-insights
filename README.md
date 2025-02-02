# Zesty K8s Helm Chart

> Helm chart for Zesty k8s

## Installation

> IMPORTANT: There are several prerequisites that are needed for the Zesty
> agent to work. You can get those, as well as a detailed instructions on
> the Zesty platform.

1. Add the Zesty helm chart repo to your client configuration
```sh
helm repo add zesty https://zesty-co.github.io/kompass-insights
helm repo update
```
2. Search the repo to make sure it's set up
```
$ helm search repo zesty
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
zesty/kompass-insights  1.1.0           1.62.2          A Helm chart for Kubernetes
```
3. Install the chart
```sh
helm install zesty-k8s zesty/kompass-insights --namespace zesty-system --create-namespace -f values.yaml
```

## Uninstalling
```sh
helm delete zesty
```
