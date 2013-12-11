package WWW::Vimeo::Reader;
use Moose;
with 'HTML::Robot::Scrapper::Reader';
use Data::Printer;
use JSON::XS;
use utf8;

our $VERSION = 0.07;

has video_id    => ( is => 'rw' );
has options     => ( is => 'rw' );

sub on_start {
  my ( $self )  = @_;
  my $video_id  = $self->options->{ video };
    ($video_id) = $video_id =~ m!vimeo.com/(\d{5,})!ig 
             if $video_id !~ m/^\d{5,}$/;
  $self->video_id( $video_id );
  warn "Downloading: " . $self->video_id;
  $self->append( search => 'http://www.vimeo.com/' . $self->video_id );
}

sub search {
  my ( $self )        = @_;
  my ( $stuff, $key ) = $self->robot->useragent->content =~ m!data-config-url="([^"]+)&amp;s=([a-zA-Z0-9]+)"!g;
# $self->append( video_metadata => "http://player.vimeo.com/v2/video/".$self->video_id."/config?byline=0&bypass_privacy=1&context=clip.main&default_to_hd=1&portrait=0&title=0&s=".$key );
  $self->append( video_metadata => "http://player.vimeo.com/v2/video/".$self->video_id."/config" );
  warn p "http://player.vimeo.com/v2/video/".$self->video_id."/config";
}

sub video_metadata {
  my ( $self ) = @_;
  my $metadata            = $self->robot->parser->json;
  my $first_format_avail  = $metadata->{ request }->{ files }->{ codecs }[0];
  my $video_url;
  foreach my $fmt ( qw/hd sd mobile/ ) {
    warn $fmt;
    $video_url = $metadata->{ request }->{ files }->{ $first_format_avail }->{ $fmt }->{ url }
    if exists $metadata->{ request }->{ files }->{ $first_format_avail }
    and exists $metadata->{ request }->{ files }->{ $first_format_avail }->{ $fmt }
    and exists $metadata->{ request }->{ files }->{ $first_format_avail }->{ $fmt }->{ url };
    if (defined $video_url) {
      $self->append( video_url => $video_url, { 
          passed_key_values => { 
              metadata => $metadata 
          }
      } );
      last;
    }
  }
}

sub video_url {
  my ( $self ) = @_;
  $self->robot->writer->save( { 
    video     => $self->robot->useragent->content ,
    video_id  => $self->video_id,
    metadata  => $self->passed_key_values->{ metadata },
    options   => $self->options,
  } );
}

sub on_link {
    my ( $self, $url ) = @_;
}

sub on_finish {
    my ( $self ) = @_;
#   $self->robot->writer->save( "bla" );
    $self->options( undef );
    $self->video_id( undef );
    $self->robot->queue->url_list_hash({});
}

1;
