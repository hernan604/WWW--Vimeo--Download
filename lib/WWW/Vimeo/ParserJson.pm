package WWW::Vimeo::ParserJson;
use Moose::Role;
use JSON::XS;

has json => (
    is => 'rw',
);

=head2 parse_json

will parse the current content with JSON::XS

then will keep the result in $self->json attribute

=cut

sub parse_json {
    my ($self, $content ) = @_;
    $content = $self->robot->encoding->safe_encode( $content );
    $self->json( decode_json( $content ) );
}

1;

