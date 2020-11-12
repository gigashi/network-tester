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
	port := flag.Int("port", 8080, "listen port")
	udp := flag.Bool("udp", false, "use UDP")
	echo := flag.Bool("echo", false, "echo receive data (TCP only)")
	bufSize := flag.Int("buf-size", 4096, "buffer size")
	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	// 1接続のみ 後から来た接続要求には反応しない 切断時再接続もなし
	conn, err := listen(*udp, *port)
	if err != nil {
		log.Fatalln(err)
	}
	defer conn.Close()

	buf := make([]byte, *bufSize)
	for {
		readCount, err := conn.Read(buf)
		if err != nil {
			if err == io.EOF {
				fmt.Fprintln(os.Stderr, "\nEOF")
				os.Exit(0)
			}
			log.Fatalln(err)
		}
		receiveData := make([]byte, readCount)
		copy(receiveData, buf[0:readCount-1])

		// TODO: 1回のwriteで送信しきれない場合を考慮
		os.Stdout.Write(receiveData)
		if *echo && !*udp {
			conn.Write(receiveData)
		}
	}
}

// TCPでもUDPでも同じインタフェースで返す
func listen(useUDP bool, port int) (Connection, error) {
	// UDP
	if useUDP {
		fmt.Fprintf(os.Stderr, "Listen UDP port: %d\n", port)

		// XXX: windowsはudp, udp6で繋がらず
		conn, err := net.ListenUDP("udp4", &net.UDPAddr{
			Port: port,
		})
		if err != nil {
			return nil, err
		}

		return conn, err
	}

	// TCP
	fmt.Fprintf(os.Stderr, "Listen TCP port: %d\n", port)
	listen, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		return nil, err
	}
	defer listen.Close()

	conn, err := listen.Accept()
	if err != nil {
		return nil, err
	}
	fmt.Fprintf(os.Stderr, "accept address: %s\n", conn.RemoteAddr().String())

	return conn, nil
}

// Connection TCPとUDPの共通化 net.Connとnet.UDPConn
type Connection interface {
	Read(b []byte) (int, error)
	Write(b []byte) (int, error)
	Close() error
}
