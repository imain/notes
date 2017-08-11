#!/bin/bash

set -ux


### --start_docs
## Deploying the overcloud
## =======================

## Prepare Your Environment
## ------------------------

## * Source in the undercloud credentials.
## ::

source /home/stack/stackrc

### --stop_docs
# Wait until there are hypervisors available.
while true; do
    count=$(openstack hypervisor stats show -c count -f value)
    if [ $count -gt 0 ]; then
        break
    fi
done

### --start_docs

openstack overcloud deploy \
    --templates /usr/share/openstack-tripleo-heat-templates \
    --libvirt-type qemu  --timeout 80 -e /home/stack/cloud-names.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/deployed-server-environment.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/deployed-server-bootstrap-environment-centos.yaml  -e /usr/share/openstack-tripleo-heat-templates/ci/environments/scenario001-multinode-containers.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/docker-network.yaml -e /home/stack/containers-default-parameters.yaml   -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml      --validation-errors-nonfatal  --compute-scale 0 -e /usr/share/openstack-tripleo-heat-templates/environments/debug.yaml --overcloud-ssh-user stack

exit 0
 #\
    #${DEPLOY_ENV_YAML:+-e $DEPLOY_ENV_YAML} "$@" && status_code=0 || status_code=$?
## * Deploy the overcloud!
## ::
#openstack overcloud deploy \
    #--templates /usr/share/openstack-tripleo-heat-templates \
    #--libvirt-type qemu --control-flavor oooq_control --compute-flavor oooq_compute --ceph-storage-flavor oooq_ceph --block-storage-flavor oooq_blockstorage --swift-storage-flavor oooq_objectstorage --timeout 90 -e /home/stack/cloud-names.yaml   -e /usr/share/openstack-tripleo-heat-templates/environments/puppet-pacemaker.yaml -e /home/stack/neutronl3ha.yaml  -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml -e /home/stack/network-environment.yaml -e /home/stack/resource-registry-nic-configs.yaml -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml     -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml         --control-flavor baremetal --compute-flavor baremetal --ntp-server pool.ntp.org  \
    #${DEPLOY_ENV_YAML:+-e $DEPLOY_ENV_YAML} "$@" && status_code=0 || status_code=$?
#
#### --stop_docs

# Check if the deployment has started. If not, exit gracefully. If yes, check for errors.
if ! openstack stack list | grep -q overcloud; then
    echo "overcloud deployment not started. Check the deploy configurations"
    exit 1

    # We don't always get a useful error code from the openstack deploy command,
    # so check `openstack stack list` for a CREATE_COMPLETE or an UPDATE_COMPLETE
    # status.
elif ! openstack stack list | grep -Eq '(CREATE|UPDATE)_COMPLETE'; then
        # get the failures list
    openstack stack failures list overcloud --long > /home/stack/failed_deployment_list.log || true
    
    # get any puppet related errors
    for failed in $(openstack stack resource list \
        --nested-depth 5 overcloud | grep FAILED |
        grep 'StructuredDeployment ' | cut -d '|' -f3)
    do
    echo "heat deployment-show output for deployment: $failed" >> /home/stack/failed_deployments.log
    echo "######################################################" >> /home/stack/failed_deployments.log
    heat deployment-show $failed >> /home/stack/failed_deployments.log
    echo "######################################################" >> /home/stack/failed_deployments.log
    echo "puppet standard error for deployment: $failed" >> /home/stack/failed_deployments.log
    echo "######################################################" >> /home/stack/failed_deployments.log
    # the sed part removes color codes from the text
    heat deployment-show $failed |
        jq -r .output_values.deploy_stderr |
        sed -r "s:\x1B\[[0-9;]*[mK]::g" >> /home/stack/failed_deployments.log
    echo "######################################################" >> /home/stack/failed_deployments.log
    # We need to exit with 1 because of the above || true
    done
    exit 1
fi
exit $status_code
