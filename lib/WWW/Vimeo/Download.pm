package WWW::Vimeo::Download;
use Moose;
use HTML::Robot::Scrapper;
use HTTP::Tiny;
use WWW::Vimeo::Reader;
use WWW::Vimeo::Writer;
use WWW::Vimeo::Parser;

has video_id  =>  ( 
    is      => 'rw',
    reader  => 'video_id',
    writer  => 'set_video_id',
);

has robot => ( 
  is      => 'rw',
  default => sub {
    HTML::Robot::Scrapper->new(
      reader    => WWW::Vimeo::Reader->new,
      writer    => WWW::Vimeo::Writer->new,
      parser    => WWW::Vimeo::Parser->new, #custom para tb fipe. pois eles respondem com Content type text/plain
      useragent => HTML::Robot::Scrapper::UserAgent::Default->new(
        ua => HTTP::Tiny->new(
           agent => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
        )
      )
    )
  }
);

after set_video_id => sub {
  my ( $self ) = @_; 
  $self->robot->reader->video_id( $self->video_id );
  $self->robot->start();
};


1;
