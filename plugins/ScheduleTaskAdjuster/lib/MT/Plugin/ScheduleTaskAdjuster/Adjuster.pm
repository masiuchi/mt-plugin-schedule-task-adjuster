package MT::Plugin::ScheduleTaskAdjuster::Adjuster;
use strict;
use warnings;

use MT;
use MT::Session;
use MT::TaskMgr;
use MT::Util;

sub adjust_tasks {
    my $self       = shift;
    my @task_names = @_;
    my @sessions   = _get_sessions(@task_names);
    for my $sess (@sessions) {
        my $task = _get_task($sess);
        if ($task) {
            my $adjuster_offset = MT->config->AdjusterOffset * 3600;
            my $start = MT::Util::offset( $sess->start ) + $adjuster_offset;
            my $new_start = $start - ( $start % $task->frequency );
            if ( $new_start != $start ) {
                $sess->start($new_start);
                $sess->save;
            }
        }
    }
}

sub _get_sessions {
    my @task_names = @_;
    my @sessions;
    if (@task_names) {
        my @tasks    = map { $MT::TaskMgr::Tasks{$_} } @task_names;
        my @task_ids = map { 'Task:' . $_->key } @tasks;
        @sessions = MT::Session->load( { kind => 'PT', id => \@task_ids } );
    }
    else {
        @sessions = MT::Session->load( { kind => 'PT' } );
    }
    @sessions;
}

sub _get_task {
    my $sess = shift;
    my ($key) = $sess->id =~ /^Task:(.+)$/ or return;
    $MT::TaskMgr::Tasks{$key};
}

1;

