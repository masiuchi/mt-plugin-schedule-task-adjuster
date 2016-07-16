package MT::Plugin::ScheduleTaskAdjuster;
use strict;
use warnings;

use MT::TaskMgr;

use MT::Plugin::ScheduleTaskAdjuster::Adjuster;

sub init_app {
    my $run_tasks = \&MT::TaskMgr::run_tasks;
    no warnings 'redefine';
    *MT::TaskMgr::run_tasks = sub {
        my $ret = $run_tasks->(@_);
        shift;
        my @task_names = @_;
        MT::Plugin::ScheduleTaskAdjuster::Adjuster->adjust_tasks(@task_names);
    };
}

1;

