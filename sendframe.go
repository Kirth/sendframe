package main

import (
    "fmt"
    "log"
    "net"
    "os"

    "github.com/google/gopacket"
    "github.com/google/gopacket/layers"
    "github.com/google/gopacket/pcap"
)

func main() {
    if len(os.Args) != 4 {
        fmt.Printf("Usage: %s <interface> <destination MAC> <message>\n", os.Args[0])
        os.Exit(1)
    }

    ifaceName := os.Args[1]
    destMACStr := os.Args[2]
    message := os.Args[3]

    iface, err := net.InterfaceByName(ifaceName)
    if err != nil {
        log.Fatalf("Could not find interface %s: %v", ifaceName, err)
    }

    destMAC, err := net.ParseMAC(destMACStr)
    if err != nil {
        log.Fatalf("Invalid destination MAC address: %v", err)
    }

    // note: opening raw sockets requires root
    handle, err := pcap.OpenLive(iface.Name, 65536, false, pcap.BlockForever)
    if err != nil {
        log.Fatalf("Error opening device %s: %v", iface.Name, err)
    }
    defer handle.Close()

    eth := layers.Ethernet{
        SrcMAC:       iface.HardwareAddr,
        DstMAC:       destMAC,
        EthernetType: layers.EthernetTypeIPv4, // see https://github.com/google/gopacket/blob/v1.1.19/layers/enums.go#L30, you may need IPv6?
    }

    payload := gopacket.Payload([]byte(message))

    buffer := gopacket.NewSerializeBuffer()
    opts := gopacket.SerializeOptions{
        FixLengths:       true,
        ComputeChecksums: true,
    }

    err = gopacket.SerializeLayers(buffer, opts, &eth, payload)
    if err != nil {
        log.Fatalf("Failed to serialize layers: %v", err)
    }

    err = handle.WritePacketData(buffer.Bytes())
    if err != nil {
        log.Fatalf("Failed to send dataframe: %v", err)
    }

    fmt.Println("Dataframe sent successfully!")
}

