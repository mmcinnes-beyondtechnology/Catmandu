package Catmandu::Exporter::CSV;

use Catmandu::Sane;
use Moo;
use Text::CSV;

with 'Catmandu::Exporter';

has csv        => (is => 'ro', lazy => 1, builder => '_build_csv');
has quote_char => (is => 'ro', default => sub { '"' });
has split_char => (is => 'ro', default => sub { ',' });
has header     => (is => 'ro', default => sub { 1 });
has fields => (
    is     => 'rw',
    coerce => sub {
        my $fields = $_[0];
        given (ref $fields) {
            when ('ARRAY') { return $fields }
            when ('HASH')  { return [keys %$fields] }
            default        { return [split ',', $fields] }
        }
    },
);

sub _build_csv {
    my ($self) = @_;
    Text::CSV->new({
        binary     => 1,
        eol        => "\n",
        quote_char => $self->quote_char,
        sep_char   => $self->split_char,
    });
}

sub add {
    my ($self, $data) = @_;
    my $fields = $self->fields || $self->fields($data);
    my $row = [map {
        my $val = $data->{$_} // "";
        $val =~ s/\t/\\t/g;
        $val =~ s/\n/\\n/g;
        $val =~ s/\r/\\r/g;
        $val;
    } @$fields];
    my $fh = $self->fh;
    if ($self->count == 0 && $self->header) {
        $self->csv->print($fh, $fields);
    }
    $self->csv->print($fh, $row);
}

1;