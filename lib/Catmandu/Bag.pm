package Catmandu::Bag;

use Catmandu::Sane;
use Catmandu::Util qw(:check new_id);
use Moo::Role;

with 'Catmandu::Pluggable';
with 'Catmandu::Iterable';
with 'Catmandu::Add';

requires 'get';
requires 'add';
requires 'delete';
requires 'delete_all';

has store => (is => 'ro', required => 1);
has name  => (is => 'ro', required => 1);

before get => sub {
    check_string($_[1]);
};

around add => sub {
    my ($orig, $self, $data) = @_;
    check_hash_ref($data)->{_id} ||= new_id;
    $orig->($self, $data);
    $data;
};

before delete => sub {
    check_string($_[1]);
};

sub commit { 1 }

sub get_or_add {
    my ($self, $id, $data) = @_;
    check_string($id);
    check_hash_ref($data);
    $self->get($id) || do {
        $data->{_id} = $id;
        $self->add($data);
    };
}

1;
