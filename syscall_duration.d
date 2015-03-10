
#pragma D option quiet

syscall:::entry
/pid == $target/
{
    self->entry_ts = timestamp;
}

syscall:::return
/pid == $target && self->entry_ts/
{
    this->duration = timestamp - self->entry_ts;
    @syscall_durations[probefunc] = avg(this->duration);
    @syscall_counts[probefunc] = count();
    printf("%s duration: %d\n", probefunc, this->duration);
}

