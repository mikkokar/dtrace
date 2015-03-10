#!/usr/sbin/dtrace -qs

/*
 * To use, need to activate extended Java DTrace probes:
 *
 * -XX:+ExtendedDTraceProbes
 */

dtrace:::BEGIN
{
    printf("Tracing for process $1 ... Hit Ctrl-C to end.\n");
}

hotspot*:::object-alloc
{
  this->method = (char *)copyin(arg1, arg2 + 1);
  this->method[arg2] = '\0';

  printf("%d:%d: %s -> %d\n", pid, arg0, stringof(this->method), arg3);

  @mem_per_thread[arg0] = sum(arg3)
}

