package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
)

func main() {
	help := flag.Bool("help", false, "show this message")
	server := flag.String("server", "", "connect address (e.g. 192.168.1.1 example.com)")
	port := flag.Int("port", 80, "connect port")
	udp := flag.Bool("udp", false, "use UDP")
	bufSize := flag.Int("buf-size", 4096, "buffer size")
	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	if *server == "" {
		println("required --server <address>")
		os.Exit(1)
	}

	mode := "tcp"
	if *udp {
		mode = "udp"
	}

	conn, err := net.Dial(mode, fmt.Sprintf("%s:%d", *server, *port))
	if err != nil {
		log.Fatalln(err)
	}
	defer conn.Close()

	buf := make([]byte, *bufSize)
	for {
		readCount, err := os.Stdin.Read(buf)
		if err != nil {
			if err == io.EOF {
				fmt.Fprintln(os.Stderr, "EOF")
				os.Exit(0)
			}
			log.Fatalln(err)
		}
		writeData := make([]byte, readCount)
		copy(writeData, buf[0:readCount-1])

		// TODO: 1回のwriteで送信しきれない場合を考慮
		_, err = conn.Write(writeData)
		if err != nil {
			log.Fatalln(err)
		}
	}
}
