# sendframe

Send raw Ethernet frames to a MAC address using the `gopacket` library. 

```
docker build -t sendframe .
sudo docker run --rm -it --net=host --privileged sendframe <interface> <destination MAC> <ASCII message>
```

Note that socket operations such as *sending dataframes* usually *require root permissions*.

## Verifying Receipt

On the target machine, run tcpdump -X and check for the ascii message:
```
sudo tcpdump -i <interface> -nn -e -X | grep "Test Message"
```



