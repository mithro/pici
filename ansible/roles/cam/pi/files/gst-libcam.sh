#!/bin/bash -x


while [ "$(/usr/bin/hostname --short)" = "localhost" ]
do
    # this should really be in its own systemd script.
    # it works around some bug in
    # https://github.com/isc-projects/dhcp/blob/master/client/scripts/linux#L121
    reboot
done

hn=$(/usr/bin/hostname --short)

# find the upstream IP
ip=$(ip -json route show default | jq ".[0].gateway" --raw-output)
RTMP_DEST=rtmp://${ip}/pib/${hn}

/usr/bin/gst-launch-1.0 libcamerasrc ! \
    video/x-raw,colorimetry=bt709,format=NV12,interlace-mode=progressive,framerate=6/1 ! \
    v4l2h264enc extra-controls=controls,video_bitrate_mode=0,video_bitrate=1000000,repeat_sequence_header=1 ! \
    video/x-h264,profile=high,level=\(string\)4.2 ! \
    h264parse ! \
    queue ! flvmux ! \
    rtmpsink location=$RTMP_DEST

exit

# or use nfs to get data to nginx... no.

cd /srv/streaming-frontend/gst
# mkdir -p ${hn}
# cd ${hn}
rm *

/usr/bin/gst-launch-1.0 libcamerasrc ! \
    video/x-raw,colorimetry=bt709,format=NV12,interlace-mode=progressive,framerate=6/1 ! \
    v4l2h264enc extra-controls=controls,video_bitrate_mode=0,video_bitrate=1000000,repeat_sequence_header=1 ! \
    video/x-h264,profile=high,level=\(string\)4.2 ! \
    h264parse ! \
    queue ! \
    mpegtsmux ! \
    hlssink max-files=5



