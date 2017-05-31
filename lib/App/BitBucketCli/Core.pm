package App::BitBucketCli::Core;

# Created on: 2017-04-24 08:14:30
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use WWW::Mechanize;
use JSON::XS qw/decode_json encode_json/;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use App::BitBucketCli::Branch;
use App::BitBucketCli::PullRequest;

our $VERSION = 0.001;

has url => (
    is      => 'rw',
    builder => '_url',
    lazy    => 1,
);
has host => (
    is      => 'rw',
    required => 1,
);
has [qw/user pass/] => (
    is  => 'rw',
);
has mech => (
    is      => 'rw',
    default => sub { WWW::Mechanize->new },
);
has opt => (
    is      => 'rw',
    default => sub {{}},
);

sub projects {
    my ($self) = @_;
    my @projects;
    my $last_page = 0;
    my $next_page_start = 0;
    my $limit = 30;

    while ( ! $last_page ) {
        my $json;
        eval {
            $json = $self->_get($self->url . "/projects?limit=$limit&start=$next_page_start");
            1;
        } || do {
            warn "Couldn't list repositories: $@\n";
            return [];
        };
        push @projects, @{ $json->{values} };
        $last_page = $json->{isLastPage};
        $next_page_start = $json->{nextPageStart};
    }

    die Dumper \@projects;
}

sub branch {
    my ($self, @branches) = @_;

    my $branches = $self->get_branches($self->opt->{project}, $self->opt->{repository});

    for my $branch (sort keys %{ $branches }) {
        next if !grep {$branch eq $_} @branches;
        print "$branch\n";
    }

    return;
}

sub get_pull_requests {
    my ($self, $project, $repository) = @_;
    my $json;
    my @prs;

    eval {
        $json = $self->_get($self->url . "/projects/$project/repos/$repository/pull-requests");
    };
    if ($@) {
        warn "Couldn't get pull requests for $project/$repository\n";
        return [];
    }

    for my $pr (@{ $json->{values} }) {
        push @prs, App::BitBucketCli::PullRequest->new($pr);
    }

    return \@prs;
}

sub get_branches {
    my ($self, $project, $repository) = @_;
    my $json;
    my @branches;

    eval {
        $json = $self->_get($self->url . "/projects/$project/repos/$repository/branches?orderBy=MODIFICATION&details=true&limit=100");
    };
    my $error = $@;
    if ($error) {
        if ($error =~ /Unauthorized/) {
            warn "Unauthorized, please try resetting your password!\n";
            exit 10;
        }

        warn "Couldn't get branches of $project/$repository\n";
        return [];
    }

    for my $branch (@{ $json->{values} }) {
        $branch->{project}    = $project;
        $branch->{repository} = $repository;
        push @branches, App::BitBucketCli::Branch->new($branch);
    }

    return \@branches;
}

sub _get {
    my ($self, $url) = @_;

    $self->mech->get($url);

    return decode_json($self->mech->content);
}

sub _url {
    my ($self) = @_;
    my $url = "https://"
        . _url_encode($self->user)
        . ':'
        . _url_encode($self->pass)
        . '@'
        . $self->host
        . "/rest/api/1.0";

    return $url;
}

sub _url_encode {
    my $str = shift;
    $str =~ s/(\W)/sprintf('%%%x',ord($1))/eg;
    return $str;
}

1;

__END__

=head1 NAME

App::BitBucketCli::Core - Library for talking to BitBucket Server (or Stash)

=head1 VERSION

This documentation refers to App::BitBucketCli::Core version 0.0.1


=head1 SYNOPSIS

   use App::BitBucketCli::Core;

   # create a stash object
   my $stash = App::BitBucketCli::Core->new(
       url => 'http://stash.example.com/',
   );

   # Get a list of open pull requests for a repository
   my $prs = $stash->pull_requests($project, $repository);

=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: App::BitBucketCli::Core -

Description:

=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2017 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
