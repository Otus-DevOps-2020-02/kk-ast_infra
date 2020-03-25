#!/bin/bash
gcloud compute instances create reddit-app \
        --boot-disk-size=10GB --image-family reddit-full \
        --machine-type=f1-micro --tags puma-server --restart-on-failure \
        --metadata-from-file startup-script=../files/service.sh
