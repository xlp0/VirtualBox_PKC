#! /bin/bash

vagrant halt

check_guestadditions_installed="$(vagrant plugin list | grep "vbguest")"

if [ "$check_guestadditions_installed" = "vagrant-vbguest (0.29.0, global)" ]; then
    echo "Found $check_guestadditions_installed, proceed with vagrant up..."
else
    echo "Need vagrant guest additions, installing the software for vagrant ..."
    vagrant plugin install vagrant-vbguest
fi

vagrant up