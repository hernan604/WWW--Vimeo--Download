package WWW::Vimeo::Download;
use Moose;
use HTML::Robot::Scrapper;
use HTTP::Tiny;
use WWW::Vimeo::Reader;
use WWW::Vimeo::Writer;
use WWW::Vimeo::Parser;
use utf8;

our $VERSION = '0.07';

has robot => (
  is      => 'rw',
  default => sub {
    HTML::Robot::Scrapper->new(
      reader    => WWW::Vimeo::Reader->new,
      writer    => WWW::Vimeo::Writer->new,
      parser    => WWW::Vimeo::Parser->new,
      useragent => HTML::Robot::Scrapper::UserAgent::Default->new(
        ua => HTTP::Tiny->new(
           agent => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
        )
      )
    )
  }
);


#usage:
#
#->download( video => "http://vimeo.com/64507066" )
#->download( video => 21312321, save_as => "/music/some_name.mp4" )
#->download( video => 99292922, name_id => "/music/{title}.{ext}", )
#So there are 2 variables used as name template: {title} {ext}
sub download {
    my ( $self, %args ) = @_; 
#   use DDP;    warn p $args{video_id};
    $self->robot->reader->options( \%args );
    $self->robot->start();
}

=head1 NAME

    WWW::Vimeo::Download - interface to download vimeo videos

=head1 SYNOPSIS

    use WWW::Vimeo::Download;
    my $vimeo = WWW::Vimeo::Download->new;
    $vimeo->set_video_id( 78276321 );
    $vimeo->set_video_id( 78317700 );

=head1 DESCRIPTION

Since vimeo markup changes frequently, the most updated version sits on github:

  https://github.com/hernan604/WWW--Vimeo--Download

=head1 AUTHOR

Hernan Lopes
CPAN ID: HERNAN
hernanlopes < @t > gmail
https://github.com/hernan604

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut




1;
