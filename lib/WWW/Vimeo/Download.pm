package WWW::Vimeo::Download;
use Moose;
use XML::XPath;
use LWP::UserAgent;
use HTTP::Request;
use Perl6::Form;
use utf8;

our $VERSION = '0.01';
my $VER = $VERSION;

has video_id => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

has download_url => (
    is  => 'rw',
    isa => 'Str',
);

has [
    qw/caption width height duration thumbnail totalComments totalLikes totalPlays url_clean url uploader_url uploader_portrait uploader_display_name nodeId isHD privacy isPrivate isPassword isNobody embed_code filename nfo filename_nfo/
  ] => (
    is  => 'rw',
    isa => 'Any',
  );

has browser => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    default => sub {
        my $ua = LWP::UserAgent->new();
        $ua->agent('Windows IE 6');
        return $ua;
    },
);

has res => (    #browser response
    is  => 'rw',
    isa => 'Any',
);

has xml => (
    is  => 'rw',
    isa => 'Any',
);

has target_dir => (
    is      => 'rw',
    isa     => 'Str',
    default => './',
);

sub load_video {
    my ( $self, $video_id_or_url ) = @_;
    if ( defined $video_id_or_url ) {
        if ( $video_id_or_url =~ m{http://www\.vimeo\.com/([^/]+)}i ) {
            $self->video_id($1);
        }
        elsif ( $video_id_or_url =~
            m{http://vimeo.com/groups/([^/]+)/videos/([^/]+)}i )
        {
            $self->video_id($2);
        }
        else {
            $self->video_id($video_id_or_url);
        }
        $self->set_download_url();
    }
    else {
        warn "Example usage: \$self->load_video( 'VIMEO_VIDEO_ID' ) "
          and return 0;
    }
}

sub download {
    my ($self) = @_;
    warn
"Please set a video url first. ex: \$vimeo->load_video( 'http://www.vimeo.com/27855315' ) "
      and return
      if !$self->download_url;
    $self->res( $self->browser->get( $self->download_url ) );
    if ( defined $self->res and $self->res->is_success ) {
        $self->prepare_nfo;
        $self->save_nfo;
        $self->save_video( $self->res->content );
    }
}

sub save_video {
    my ( $self, $video_data ) = @_;
    my $filename =
      $self->filename( $self->target_dir . '/' . $self->filename . '.mp4' );
    open FH, ">$filename";
    print FH $video_data;
    close FH;
}

sub save_nfo {
    my ($self) = @_;
    $self->filename_nfo( $self->target_dir . '/' . $self->filename . '.nfo' );
    my $filename = $self->filename_nfo;
    open FH, ">$filename";
    print FH $self->nfo;
    close FH;
}

sub prepare_nfo {
    my ($self) = @_;

    my $info = form
"===============================================================================",
"--[ WWW::Vimeo::Download ]-----------------------------------------------------",
"                                                                               ",
"  {||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||} ",
      "[" . $self->caption . "]",
"                                                                               ",
"  .............Title: {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<} ",
      $self->caption,
"  .........Video Url: {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<} ",
      $self->url,
"  ............Author: {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<} ",
      $self->uploader_display_name,
"  ........Author Url: {<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<} ",
      $self->uploader_url,
"                                                                               ",
"                                [ REVIEW ]                                     ",
"                                                                               ",
"  {[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[} ",
      $self->thumbnail,
"                                                                               ",
"---------------------------------------------------[ version $VER by HERNAN ]--",
"==============================================================================="
      ,;
    $self->nfo($info);
}

sub title_to_filename {
    my ( $self, $title ) = @_;
    $title =~ s/\W/-/ig;
    $title =~ s/--{1,}/-/ig;
    $title =~ s/^-|-$//ig;
    $title =~
tr/àáâãäçèéêëìíîïñòóôõöùúûüýÿÀÁÂÃÄÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝ/aaaaaceeeeiiiinooooouuuuyyAAAAACEEEEIIIINOOOOOUUUUY/;
    return $title;
}

sub set_filename {
    my ($self) = @_;
    $self->filename( $self->title_to_filename( $self->caption ) );
}

sub set_download_url {
    my ($self) = @_;

    #sets the download_url for specified video
    warn "getting download_url for video id: "
      . "http://www.vimeo.com/moogaloop/load/clip:"
      . $self->video_id;
    $self->res(
        $self->browser->get(
            "http://www.vimeo.com/moogaloop/load/clip:" . $self->video_id
        )
    );
    if ( $self->res->is_success ) {
        $self->xml( XML::XPath->new( xml => $self->res->content ) );

        $self->caption( $self->xml->findvalue('/xml/video/caption') )
          and $self->set_filename;
        $self->width( $self->xml->findvalue('/xml/video/width') );
        $self->height( $self->xml->findvalue('/xml/video/height') );
        $self->duration( $self->xml->findvalue('/xml/video/duration') );
        $self->thumbnail( $self->xml->findvalue('/xml/video/thumbnail') );
        $self->totalComments(
            $self->xml->findvalue('/xml/video/totalComments') );
        $self->totalLikes( $self->xml->findvalue('/xml/video/totalLikes') );
        $self->totalPlays( $self->xml->findvalue('/xml/video/totalPlays') );
        $self->url_clean( $self->xml->findvalue('/xml/video/url_clean') );
        $self->url( $self->xml->findvalue('/xml/video/url') );
        $self->uploader_url( $self->xml->findvalue('/xml/video/uploader_url') );
        $self->uploader_portrait(
            $self->xml->findvalue('/xml/video/uploader_portrait') );
        $self->uploader_display_name(
            $self->xml->findvalue('/xml/video/uploader_display_name') );
        $self->nodeId( $self->xml->findvalue('/xml/video/nodeId') );
        $self->isHD( $self->xml->findvalue('/xml/video/isHD') );
        $self->privacy( $self->xml->findvalue('/xml/video/privacy') );
        $self->isPrivate( $self->xml->findvalue('/xml/video/isPrivate') );
        $self->isPassword( $self->xml->findvalue('/xml/video/isPassword') );
        $self->isNobody( $self->xml->findvalue('/xml/video/isNobody') );
        $self->embed_code( $self->xml->findvalue('/xml/video/embed_code') );

        my $request_signature = $self->xml->findvalue('/xml/request_signature');
        my $request_signature_expires =
          $self->xml->findvalue('/xml/request_signature_expires');
        my $caption = $self->xml->findvalue('/xml/video/caption');
        my $is_hd   = $self->xml->findvalue('/xml/video/isHD');
        my $quality = 'sd';
        $quality = 'hd' if ( $is_hd eq '1' );
        my $download_url_with_req_id =
            "http://www.vimeo.com/moogaloop/play/clip:"
          . $self->video_id . "/"
          . $request_signature . "/"
          . $request_signature_expires . "/?q="
          . $quality;

        $self->res(
            $self->browser->request(
                HTTP::Request->new( HEAD => $download_url_with_req_id )
            )
        );
        my $video_download_url = $self->res->request->uri;
        if ( defined $video_download_url ) {
            $self->download_url( $video_download_url->as_string );
        }
        $self->xml(undef);
    }
    else {
        warn "Could not get success response for req. error: "
          . $self->res->status_line;
    }

}

=head1 NAME

    WWW::Vimeo::Download - interface to download vimeo videos

=head1 SYNOPSIS

    use WWW::Vimeo::Download;
    my $vimeo = WWW::Vimeo::Download->new();
    $vimeo->load_video( 'XYZ__ID_VIDEO' );        #REQ videoid or video url
    $vimeo->target_dir( '/home/catalyst/tmp/' );  #OPTIONAL target dir
    $vimeo->download();                           #start download
    print $vimeo->download_url;                   #print the url for download

=head1 DESCRIPTION


=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    hernan < @t > gmail
    https://github.com/hernan604

=head1 COPYRIGHT

    This program is free software; you can redistribute
    it and/or modify it under the same terms as Perl itself.

    The full text of the license can be found in the
    LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;

# The preceding line will help the module return a true value

