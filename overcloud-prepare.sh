### --start_docs
## Prepare the undercloud for deploying the containerized compute node
## ===================================================================

## .. note:: In progress documentation is available at https://etherpad.openstack.org/p/tripleo-containers-work
## ::

## Prepare Your Environment
## ------------------------

## * Populate the docker registry
## ::

openstack overcloud container image prepare \
    --images-file /home/stack/overcloud_containers.yaml \
    --namespace tripleo \
    --tag tripleo-ci-testing \
    --pull-source trunk.registry.rdoproject.org \
    --exclude ceph \
    --push-destination 192.168.24.1:8787

openstack overcloud container image upload --verbose --config-file /home/stack/overcloud_containers.yaml


## * Configure the /home/stack/containers-default-parameters.yaml, this is done automatically.
## ::

openstack overcloud container image prepare \
    --env-file /home/stack/containers-default-parameters.yaml \
    --tag tripleo-ci-testing \
    --namespace 192.168.24.1:8787/tripleo

echo "  DockerInsecureRegistryAddress: 192.168.24.1:8787" >> \
    /home/stack/containers-default-parameters.yaml

echo "============================="
echo "Containers default parameters:"
cat /home/stack/containers-default-parameters.yaml
echo "============================="

## * Get the journal logs for docker
## ::

sudo journalctl -u docker > docker_journalctl.log

### --stop_docs
