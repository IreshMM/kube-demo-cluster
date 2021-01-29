# Add control plane hosts
echo "[control_plane]" >hosts
for instance in controller-{0..2}; do
    EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

    echo "${EXTERNAL_IP} ansible_user=iresh hostname=${instance}" >>hosts
done

echo >>hosts

echo "[workers]" >>hosts
for instance in worker-{0..0}; do
    EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
        --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

    echo "${EXTERNAL_IP} ansible_user=iresh hostname=${instance}" >>hosts
done