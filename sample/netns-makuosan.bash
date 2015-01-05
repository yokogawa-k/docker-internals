#!/bin/bash

BRIGDE_NAME="testbr"
# ip link add ${BRIGDE_NAME} type bridge
# ip link set ${BRIGDE_NAME} up
# ip addr add 192.168.1.1/24 dev ${BRIGDE_NAME}
for i in {1..20};do
  set -x
  NUM=$(printf "%02d" ${i})
  IPADDRESS=192.168.1.${i}2
  HOST_DEV=host-veth${NUM}
  GUEST_DEV=guest-veth${NUM}
  NS_NAME=testns${NUM}
  ip link add ${HOST_DEV} type veth peer name ${GUEST_DEV}
  ip link set dev ${HOST_DEV} master ${BRIGDE_NAME}
  ip link set ${HOST_DEV} up
  ip netns add ${NS_NAME}
  ip link set ${GUEST_DEV} netns ${NS_NAME}
  ip netns exec ${NS_NAME} ip addr add ${IPADDRESS}/24 dev ${GUEST_DEV}
  ip netns exec ${NS_NAME} ip link set ${GUEST_DEV} up
  ip netns exec ${NS_NAME} ip route add 224.0.0.0/24 dev ${GUEST_DEV}
  ip netns exec ${NS_NAME} /opt/local/app/makuosan/sbin/makuosan -b /opt/local/contents/ -U /opt/local/var/makuosan/makuo${NUM}.sock
  # debug:
  #  ip netns exec ${NS_NAME} /bin/bash
  set +x
done

