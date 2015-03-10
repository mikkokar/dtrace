
#pragma D option quiet


syscall::bind:entry
/execname == "java"/
{
    socks = (struct sockaddr *)copyin(arg1, arg2);

    hport = (uint_t)socks->sa_data[0];
    lport = (uint_t)socks->sa_data[1];
    hport <<= 8;

    self->bind_socket = arg0;
    self->bind_port = hport + lport;
}

syscall::bind:return
/execname == "java"/
{
    /* Error codes can be found in:

/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/sys/errno.h

     */

    /* 
      printf("%s called socket=%d, port=%d, return=%d, errno=%d\n", 
	probefunc, self->bind_socket, self->bind_port, arg0, errno); 
     */
}

syscall::getsockname:entry
/execname == "java"/
{
    self->address = arg1;
    self->address_length = arg2;
    self->getsockname_socket = arg0
}

syscall::getsockname:return
/execname == "java"/
{
    length_addr = (socklen_t *)copyin(self->address_length, sizeof(socklen_t));
    length = *length_addr;

    socks = (struct sockaddr *)copyin(self->address, length);

    hport = (uint_t)socks->sa_data[0];
    lport = (uint_t)socks->sa_data[1];
    hport <<= 8;
    port = hport + lport;

    printf("%s called socket=%d, port=%d, return=%d, errno: %d\n",
	probefunc, self->getsockname_socket, port, arg0, errno);
}

syscall::socket:return
/execname == "java"/
{
    printf("%s called socket=%d\n", probefunc, arg0);
}

/*
syscall::close:entry
/execname == "java"/
{
    printf("%d: %d: %s called socket=%d\n", pid, tid, probefunc, arg0);
}
*/

/* print the errno after any failing syscall: */
/*
syscall:::return
/errno != 0/
{
    printf("%s: system call %s returned: %d, errno: %d\n", execname, probefunc, arg0, errno);
}
*/

