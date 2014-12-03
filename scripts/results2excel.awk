#!/usr/bin/awk -f

function print_results() {
    print fname,
	  "",
	  null_call,
	  (null_IO_read + null_IO_write) / 2,
	  lat_stat, lat_fstat, lat_openclose,
	  select_tcp_100,
	  sig_inst, sig_hndl,
	  fork_proc, exec_proc, sh_proc,
	  "",
	  intgr_bit, intgr_add, intgr_mul, intgr_div, intgr_mod,
	  "",
	  int64_bit, int64_add, int64_mul, int64_div, int64_mod,
	  "",
	  float_add, float_mul, float_div, float_bogo,
	  "",
	  double_add, double_mul, double_div, double_bogo,
	  "",
	  ctxsw_2p_0k, ctxsw_2p_16k, ctxsw_2p_64k, ctxsw_8p_16k, ctxsw_8p_64k,
	  ctxsw_16p_16k, ctxsw_16p_64k,
	  "",
	  pipe_lat, af_unix_sock_lat, udp_lat, rpc_udp_lat,
	  tcp_lat, rpc_tcp_lat, tcp_conn_lat,
	  "",
	  udp_remote_lat, rpc_udp_remote_lat, tcp_remote_lat, rpc_tcp_remote_lat,
	  tcp_conn_remote_lat,
	  "",
	  fs_create_0k, fs_delete_0k, fs_create_10k, fs_delete_10k,
	  mmap_lat, protection_fault, page_faults, fd_select_lat,
	  "",
	  pipe_bandwidth, af_unix_bandwidth, sock_bandwidth, reread_bandwidth,
	  mmap_reread_bandwidth, libc_bcopy_bandwidth, unrolled_bcopy_bandwidth,
	  mem_read_bandwidth, mem_write_bandwidth,
	  "",
	  cpu_mhz, mem_lat_l1, mem_lat_l2, mem_lat_main_mem, mem_lat_rand_mem
}

BEGIN {
    OFS=","
}

FNR == 1 {
    # if fname is not empty, than this is not the first file in a list. Print
    # out results from the previous file.
    if (fname != "") {
	print_results()

	# Clear values
	null_call = null_IO_read = null_IO_write = lat_stat = lat_fstat = \
	select_tcp_100 = sig_inst = sig_hndl = fork_proc = exec_proc = sh_proc = \
	intgr_bit = intgr_add = intgr_mul = intgr_div = intgr_mod = \
	int64_bit = int64_add = int64_mul = int64_div = int64_mod = \
	float_add = float_mul = float_div = float_bogo = \
	double_add = double_mul = double_div = double_bogo = \
	ctxsw_2p_0k = ctxsw_2p_16k = ctxsw_2p_64k = ctxsw_8p_16k = ctxsw_8p_64k = \
	ctxsw_16p_16k = ctxsw_16p_64k = \
	pipe_lat = af_unix_sock_lat = udp_lat = rpc_udp_lat = tcp_lat = \
	rpc_tcp_lat = tcp_conn_lat = \
	udp_remote_lat = rpc_udp_remote_lat = tcp_remote_lat = rpc_tcp_remote_lat = \
	tcp_conn_remote_lat = \
	fs_create_0k = fs_delete_0k = fs_create_10k = fs_delete_10k = \
	mmap_lat = protection_fault = page_faults = fs_select_lat = \
	pipe_bandwidth = af_unix_bandwidth = sock_bandwidth = reread_bandwidth = \
	mmap_reread_bandwidth = libc_bcopy_bandwidth = unrolled_bcopy_bandwidth = \
	mem_read_bandwidth = mem_write_bandwidth = \
	mem_lat_l1 = mem_lat_l2 = mem_lat_main_mem = mem_lat_rand_mem = \
	""
    }

    filename_arr_sz = split(FILENAME, filename_arr, /\//)
    fname = filename_arr[filename_arr_sz]
}

# Basic info
/^\[MHZ:/ { cpu_mhz = $2 }

# Processes
/^Simple syscall:/ { null_call = $3 }
/^Simple read:/ { null_IO_read = $3 }
/^Simple write:/ { null_IO_write = $3 }
/^Simple stat:/ { lat_stat = $3 }
/^Simple fstat:/ { lat_fstat = $3 }
/^Simple open\/close:/ { lat_openclose = $3 }
/^Select on 100 tcp fd's:/ { select_tcp_100 = $6 }
/^Signal handler installation:/ { sig_inst = $4 }
/^Signal handler overhead:/ { sig_hndl = $4 }
/^Process fork\+exit:/ { fork_proc = $3 }
/^Process fork\+execve:/ { exec_proc = $3 }
/^Process fork\+\/bin\/sh -c:/ { sh_proc = $4 }

# Basic integer operations
/^integer bit:/ { intgr_bit = $3 }
/^integer add:/ { intgr_add = $3 }
/^integer mul:/ { intgr_mul = $3 }
/^integer div:/ { intgr_div = $3 }
/^integer mod:/ { intgr_mod = $3 }

# Basic uint64 ops
/^int64 bit:/ { int64_bit = $3 }
/^uint64 add:/ { int64_add = $3 }
/^int64 mul:/ { int64_mul = $3 }
/^int64 div:/ { int64_div = $3 }
/^int64 mod:/ { int64_mod = $3 }

# Basic flaot ops
/^float add:/ { float_add = $3 }
/^float mul:/ { float_mul = $3 }
/^float div:/ { float_div = $3 }
/^float bogomflops:/ { float_bogo = $3 }

# Basic double ops
/^double add:/ { double_add = $3 }
/^double mul:/ { double_mul = $3 }
/^double div:/ { double_div = $3 }
/^double bogomflops:/ { double_bogo = $3 }

# Context switching
/size=0/ {
    # 2p/0K
    getline
    ctxsw_2p_0k = $2
}

/size=16/ {
    # 2p/16K
    getline
    ctxsw_2p_16k = $2

    # 8p/16K
    getline
    getline
    ctxsw_8p_16k = $2

    # 16p/16K
    getline
    ctxsw_16p_16k = $2
}

/size=64/ {
    # 2p/64K
    getline
    ctxsw_2p_64k = $2

    # 8p/64K
    getline
    getline
    ctxsw_8p_64k = $2

    # 16p/64K
    getline
    ctxsw_16p_64k = $2
}

/^Pipe latency:/ { pipe_lat = $3 }
/^AF_UNIX sock stream latency:/ { af_unix_sock_lat = $5 }
/^UDP latency using localhost:/ { udp_lat = $5 }
/^RPC.udp latency using localhost:/ { udp_rpc_lat = $5 }
/^TCP latency using localhost:/ { tcp_lat = $5 }
/^RPC.tcp latency using localhost:/ { tcp_rpc_lat = $5 }
/^TCP.IP connection cost to localhost:/ { tcp_conn_lat = $6 }
/^UDP latency using / && $4 != "localhost" { udp_remote_lat = $5 }
/^RPC.udp latency using/ && $4 != "localhost" { udp_rpc_remote_lat = $5 }
/^TCP latency using/ && $4 != "localhost" { tcp_remote_lat = $5 }
/^RPC.tcp latency using/ && $4 != "localhost" { tcp_rpc_remote_lat = $5 }
/^TCP.IP connection cost to/ && $5 != "localhost" { tcp_conn_remote_lat = $6 }

/File system latency/ {
    # 0k
    getline
    fs_create_0k = 1000000 / $3
    fs_delete_0k = 1000000 / $4

    # 10k
    getline
    getline
    getline
    fs_create_10k = 1000000 / $3
    fs_delete_10k = 1000000 / $4
}

/^"mappings/ {
    while(match($1, /^16\./) == 0) {
	getline
    }
    mmap_lat = $2
}

/^Protection fault:/ { protection_fault = $3 }
/^Pagefaults on/ { page_faults = $4 }
/^Select on 100 fd/ { fd_select_lat = $5 }
/^Pipe bandwidth:/ { pipe_bandwidth = $3 }
/^AF_UNIX sock stream bandwidth:/ { af_unix_bandwidth = $5 }
/^Socket bandwidth using localhost/ {
    while (match($1, /^10\./) == 0) { getline }
    sock_bandwidth = $2
}
/^"read bandwidth/ {
    while (match($1, /^16\./) == 0) { getline }
    reread_bandwidth = $2
}
/^"Mmap read bandwidth/ {
    while (match($1, /^16\./) == 0) { getline }
    mmap_reread_bandwidth = $2
}
/^"libc bcopy unaligned/ {
    while (match($1, /^8\./) == 0) { getline }
    libc_bcopy_bandwidth = $2
}
/^"unrolled bcopy unaligned/ {
    while (match($1, /^8\./) == 0) { getline }
    unrolled_bcopy_bandwidth = $2
}
/^Memory read bandwidth/ {
    while (match($1, /^16\./) == 0) { getline }
    mem_read_bandwidth = $2
}
/^Memory write bandwidth/ {
    while (match($1, /^16\./) == 0) { getline }
    mem_write_bandwidth = $2
}

/^"stride=128/ {
    while (match($1, /^0\.00098/) == 0) { getline }
    mem_lat_l1 = $2
    while (match($1, /^0\.12500/) == 0) { getline }
    mem_lat_l2 = $2
    while (match($1, /^24\.00000/) == 0) { getline }
    mem_lat_main_mem = $2
}

/^"stride=16/ {
    while (match($1, /^24\.00000/) == 0) { getline }
    mem_lat_rand_mem = $2
}

END {
    # Print resutls for the last file.
    print_results()
}

