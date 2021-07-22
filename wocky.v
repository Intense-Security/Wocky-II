import server
import auth

import os
import io
import net
import time

const (
	port = 3000
)

fn main() {
	println("Welcome to Wocky-II Server-Side")
	go listener()
	// go test()
	println('[+] NET Started on Port: $port')
	for {
		mut input_cmd := os.input("[Wocky@CP]# [~]$ ")
		if input_cmd.len == 0 { return }
		// Continue CP from here
	}
}

fn listener() {
	mut server := net.listen_tcp(.ip6, ':3000') or {
		panic("[x] Error, Unable to start server!\r\n")
	}
	for {
		mut socket := server.accept() or {
			panic("[x] Error, Unable to accept the connection!\r\n")
		}
		go handle_client(mut socket)
	}
}

fn handle_client(mut socket net.TcpConn) {
	mut reader := io.new_buffered_reader(reader: socket)
	mut current_ip := socket.peer_addr() or { return } //User's IP
	println('> new client: $current_ip')

	socket.write_string("Username: ") or { panic("[x] Error") }
	socket.wait_for_read() or { panic("[x] Error") }
	username := socket.read_line().replace("\r\n","")
	socket.write_string("Password: ") or { panic("[x] Error") }
	socket.wait_for_read() or { panic("[x] Error") }
	password := socket.read_line().replace("\r\n", "")

	mut a := auth.AuthInfo{username: username, password: password}
	mut login := a.login()
	if login.contains("[+]") {
		//append user to arr
		socket.write_string(login) or { panic("[x]") }
	} else {
		socket.write_string(login) or { panic("[x]") }
		socket.close() or { panic("[x]") }
	}
	
	socket.write_string("\r\x1b[37m╔═[\x1b[35mWocky\x1b[37m@\x1b[35mII\x1b[37m]\r\n╚════➢\x1b[32m ") or { panic("[x]") }
	for {
		server.cmd_handler(mut socket)
	}
	
	reader.free()
}