use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'App::BitBucketCli',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/App/BitBucketCli.pm',
    requires          => {
        'perl'           => 5.008,
        'File::ShareDir' =>  0,
        'Moo'            => '2.0',
        'Path::Tiny'     => '0.076',
    },
    build_requires => {
        'Test::More'     => 0,
        'Test::Warnings' => 0,
    },
    share_dir => {
        dist => [
        ],
    },
    add_to_cleanup     => [ 'App-BitBucket-cli-*' ],
    create_license     => 1,
    meta_merge => {
        resources => {
            repository => 'git://github.com/ivanwills/App-bitbucket-cli.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App::BitBucketCli',
        },
    },
);

$builder->create_build_script();
