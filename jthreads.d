#!/usr/sbin/dtrace -qs

/*
 * To use, need to activate extended Java DTrace probes:
 *
 * -XX:+ExtendedDTraceProbes
 */

char *thread_names[int, int];

dtrace:::BEGIN
{
    printf("Tracing for process $1 ... Hit Ctrl-C to end.\n");
}


hotspot*:::thread-probe-start
{
   this->thread_name = (char *)copyin(arg0, arg1);
   this->thread_name[arg1] = '\0';

   this->thread_id = arg2;
   this->thread_native_id = arg3;
   this->thread_daemon = arg4;

   printf("%d: thread started thread_id=%d, native_id=%d, name=%s\n",
          pid, this->thread_id, this->thread_native_id, stringof(this->thread_name));
}

