# バイナリ送受信テスト

server起動してからclient起動
カレントディレクトリはプロジェクトルート想定

## file

```bash
cat ./testfile/binary_data | xxd -bits
```

## server

```bash
go run ./cmd/ntserver/main.go -udp | xxd -bits
```

## client

```bash
cat ./testfile/binary_data | ./bin/darwin-amd64/ntclient --server 127.0.0.1 --port 8080 -udp

```
