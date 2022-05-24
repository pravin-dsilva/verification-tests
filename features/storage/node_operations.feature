Feature: Node operations test scenarios

  # @author jhou@redhat.com
  @admin
  @destructive
  @4.11 @4.10 @4.9 @4.8 @4.7 @4.6
  Scenario Outline: Drain a node that has cloud vendor volumes
    Given environment has at least 2 schedulable nodes
    And I have a project

    # Create a deployment config
    When I run the :new_app client command with:
      | docker_image | quay.io/pdsilva1/hello-openshift@sha256:27d884a06ee89d49387a5514b7b4694c85b21fec2ad41df05033b2b33fbc02bb |
      | labels       | name=jenkins                                                                                          |
    Then the step should succeed
    And a pod becomes ready with labels:
      | name=jenkins |

    # Restore schedulable node
    Given node schedulable status should be restored after scenario
    When I run the :oadm_drain admin command with:
      | node_name         | <%= pod.node_name %> |
      | delete-local-data | true                 |
      | ignore-daemonsets | true                 |
      | force             | true                 |
    Then the step should succeed

    # Verify old pod is deleted
    And I wait for the resource "pod" named "<%= pod.name %>" to disappear

    When I run the :oadm_uncordon_node admin command with:
      | node_name | <%= pod.node_name %> |
    Then the step should succeed
    # After draining, new Pod becomes available
    And a pod becomes ready with labels:
      | name=jenkins |

    @gcp-ipi
    @gcp-upi
    Examples:
      | cloud_provider |
      | gcp            | # @case_id OCP-15287

    @azure-ipi
    @azure-upi
    Examples:
      | cloud_provider |
      | azure-disk     | # @case_id OCP-15275

    @vsphere-ipi
    @vsphere-upi
    Examples:
      | cloud_provider |
      | vsphere-volume | # @case_id OCP-15268

    @openstack-ipi
    @openstack-upi
    Examples:
      | cloud_provider |
      | cinder         | # @case_id OCP-15276

    @upgrade-sanity
    @proxy @noproxy @disconnected @connected
    @arm64 @amd64
    Examples:
      | cloud_provider |
      | aws-ebs        | # @case_id OCP-15283
