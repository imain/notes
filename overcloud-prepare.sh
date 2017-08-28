#!/bin/bash

openstack overcloud container image prepare \
    --images-file /home/stack/overcloud_containers.yaml \
    --namespace master \
    --tag tripleo-ci-testing \
    --pull-source trunk.registry.rdoproject.org \
    --exclude ceph \
    --push-destination 192.168.24.1:8787

echo "  DockerInsecureRegistryAddress: 192.168.24.1:8787" >> \
    /home/stack/containers-default-parameters.yaml

openstack overcloud container image upload --verbose --config-file /home/stack/overcloud_containers.yaml


## * Configure the /home/jenkins/containers-default-parameters.yaml, this is done automatically.
## ::

openstack overcloud container image prepare \
    --env-file /home/stack/containers-default-parameters.yaml \
    --tag tripleo-ci-testing \
    --namespace 192.168.24.1:8787/master

