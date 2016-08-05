# easyTravel-OpenShift

![easyTravel Logo](https://github.com/dynatrace-innovationlab/easyTravel-Builder/blob/images/easyTravel-logo.png)

This project deploys the [Dynatrace easyTravel](https://community.dynatrace.com/community/display/DL/Demo+Applications+-+easyTravel) demo application on [RedHat OpenShift](https://www.openshift.com).

## Application Components

| Service             | Description
|:--------------------|:-----------
| easytravel-mongodb  | A pre-populated travel database (MongoDB).
| easytravel-backend  | The easyTravel Business Backend (Java).
| easytravel-frontend | The easyTravel Customer Frontend (Java).
| easytravel-www      | A reverse-proxy for the easyTravel Customer Frontend (NGINX).

## Prerequisites

1. Access to an [OpenShift](https://www.openshift.com) environment is required. If you don't have a cluster up and running and are unsure on how to set one up, you can follow the tutorial in [README-deployOpenShiftWithAnsibleOnAWS.md](https://github.com/dynatrace-innovationlab/easyTravel-OpenShift/blob/master/README-deployOpenShiftOnAwsWithAnsible.md).
2. The [OpenShift CLI](https://docs.openshift.org/latest/cli_reference/get_started_cli.html) has to be installed.
3. Configuration for deploying easyTravel on OpenShift is stored in [config/os-settings.sh](https://github.com/dynatrace-innovationlab/easyTravel-OpenShift/blob/master/config/os-settings.sh). Adapt to suit your needs.

## Running easyTravel on OpenShift

### 0. Bootstrap

Login as *system:admin* and grant rights to user *admin* via:

```
oc login https://${OS_MASTER_IP}:8443 -u system:admin
oc new-project easytravel
oc adm policy add-role-to-user cluster-admin admin -n easytravel
oc adm policy add-scc-to-user anyuid -z default -n easytravel
```

### 1. Deploy

`./deploy.sh` deploys easyTravel on OpenShift. Undo via `./clean.sh`.

### 2. Expose Services

- Configure a [route](https://docs.openshift.com/enterprise/latest/dev_guide/routes.html) in OpenShift to expose easyTravel services to the public (provided you have configured a domain for OpenShift).
- Alternatively, you can map a pod's port to your local host via the `oc port-foward` command. The following example maps the `easytravel-www-123abc` pod's cluster internal port `80` to your local host's port `32123`. A list of available pod names is provided via `oc get pods`.

```
oc get pods (gives e.g. easytravel-www-123abc)
oc port-forward easytravel-www-123abc 32123:80
```

### 3. Apply Synthetic Load

With the `easytravel-www` service being exposed, you can apply synthetic load using the *UEM Load Generator* component from our [easyTravel-Docker](https://github.com/dynatrace-innovationlab/easyTravel-Docker) project. Suppose the service has been made available on `http://localhost:32123`:

```
docker run -ti --rm \
  --env ET_FRONTEND_URL='http://localhost:32123' \
  dynatrace/easytravel-loadgen
```

By additionally exposing the `easytravel-backend` service and providing its URL through `ET_BACKEND_URL`, the *UEM Load Generator* component will continually apply problems from an initial set of easyTravel problem patterns, as described [here](https://github.com/dynatrace-innovationlab/easyTravel-Docker). Suppose the service has been made available on `http://localhost:32124`:

```
docker run -ti --rm \
  --env ET_FRONTEND_URL='http://localhost:32123' \
  --env ET_BACKEND_URL='http://localhost:32124' \
  dynatrace/easytravel-loadgen
```

## Monitoring easyTravel with Dynatrace

Please refer to the [tutorials section](https://github.com/dynatrace-innovationlab/easyTravel-OpenShift/tree/master/tutorials/) on how to set up Dynatrace for OpenShift using Ansible.

## Additional Resources

- Blog: [Monitoring OpenShift Apps with Dynatrace](https://blog.openshift.com/openshift-ecosystem-monitoring-openshift-apps-with-dynatrace/)

## License

Licensed under the MIT License. See the [LICENSE](https://github.com/dynatrace-innovationlab/easyTravel-OpenShift/blob/master/LICENSE) file for details.