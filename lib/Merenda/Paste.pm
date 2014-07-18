package Merenda::Paste;
use Mojo::Base 'Mojolicious::Controller';
push @Merenda::Paste::ISA, 'Mojolicious::Plugin';

our $VERSION = 0.041;

use Mojo::Asset::File;
use Mojo::Util 'spurt', 'slurp';

sub register {
  my ($plugin, $app, $cfg) = @_;
  push @{$app->renderer->classes}, 'Merenda::Paste';
  push @{$app->routes->namespaces}, 'Merenda';
}

sub create {
  my $self = shift;
  my $pastie = $self->param('pastie') // '';
  return $self->render(status => 400, text => 'Sorry, missing content')
    unless $pastie =~ /\S/;

  # Store data
  my $paste_id = $self->choose_id;
  spurt $pastie => $self->app->home->rel_file("data/$paste_id");

  # Render decorated content for browsers
  return $self->redirect_to($self->url_for('paste_show', paste_id => $paste_id)
      ->query(lang => 1)) if ($self->param('destination') // '') eq 'show';

  # Render raw content
  $self->render(data => $self->url_for('paste_show', paste_id => $paste_id));
};
 
sub show {
  my $self = shift;
  return $self->redirect_to('paste_main')
    unless my $paste_id = $self->stash('paste_id');

  my $filepath = $self->app->home->rel_file("data/$paste_id");
  my $file = Mojo::Asset::File->new(path => $filepath) if -f $filepath;
  return $self->render(status => 410, data => 'Sorry, that paste has gone')
      unless $file and $file->size;

  return $self->render(pastie => slurp $filepath) if $self->param('lang');

  $self->res->content->asset($file);
  $self->res->headers->content_type('text/plain');
  $self->rendered;
}

sub edit { shift->show(@_) }

sub choose_id {
  my $self = shift;
  my $paste_id = $self->rand_char . $self->rand_char;

  my $home = $self->app->home;
  $paste_id .= $self->rand_char while -e $home->rel_file("data/$paste_id");
  return $paste_id;
}

sub rand_char {
  my $self = shift;
  my $i = int rand 62;  # 0..61
  if ($i < 10) {
    $i += 48;  # 0..9
  }
  elsif ($i < 36) {
    $i += 55;  # A..Z
  }
  else {
    $i += 61;  # a..z
  }
  return chr $i;
}

1;
__DATA__
@@ paste_main.html.ep
%= form_for paste_create => (method => 'post') => begin
  <div id="pasticular">
%#    %= text_area 'pastie', placeholder => 'Your text here', tabindex => 1, rows => 30, wrap => 'virtual', begin
    %= text_area 'pastie', placeholder => 'Your text here'
  </div>
  <div id="controls">
    %= submit_button 'Paste', tabindex => 2
  </div>
  <%= hidden_field destination => 'show' %>
% end

@@ paste_show.html.ep
% my $paste_id = stash('paste_id') // 'missing_id';
% my $pastie = stash('pastie') // '';
<div id="pasticular">
  <pre name="pastie" class="prettyprint"><code><%= $pastie %></code></pre>
</div>
<div name="controls">
  <%= link_to 'Edit', url_for('paste_edit', paste_id => $paste_id),
      class => 'btn first' %>
  <%= link_to 'New', url_for('paste_main') %>
</div>
__END__

=head1 NAME

Merenda::Paste - Integrated pastebin

=head1 SYNOPSIS

  sub startup {
    $self->plugin('Merenda::Paste');

    my $r = $self->routes;
    $r->get('/paste')                             ->name('paste_main');
    $r->post('/paste')->to('Paste#create')        ->name('paste_create');
    $r->get('/paste/:paste_id')->to('Paste#show') ->name('paste_show');
    $r->get('/paste/:paste_id/edit')->to('Paste#edit', template => 'paste_main')
                                                  ->name('paste_edit');
  }

=head1 DESCRIPTION

A pastebin applet embedded in an app and integrated (get/post) with other apps.
The target audience are developers wanting to extend their Mojolicious-based
intranet.

=head1 FEATURES

=over 4

=item *

Simple plugin for a Mojolicious app.

=item *

Paste and view via a browser.

=item *

Send and retrieve from remote client (eg curl on the commandline).

=item *

Send and retrieve from remote app (eg formatter/debugger).

=item *

Short, non-sequential identifiers.

=back

=head1 ROADMAP

=over 4

=item *

Re-edit existing paste

=item *

User-provided identifier

=item *

Syntax highlighting if type matches a list

=item *

Easy switch between highlighted and raw formats

=item *

Collate stats on user views (eg 'most recently viewed')

=item *

Publish flagged updates to the corresponding listener

=item *

Round trip with other apps (eg a formatter/tidier)

=back

=head1 INTEGRATION

=head2 Containing App

The app needs to define four routes with the names C<paste_main>,
C<paste_create>, C<paste_show>, and C<paste_edit>, with the latter two including
a placeholder called C<paste_id>.  See C<test/ExampleApp.pm> for one way of
doing it.

  /paste                 GET   "paste_main"
  /paste                 POST  "paste_create"
  /paste/:paste_id       GET   "paste_show"
  /paste/:paste_id/edit  GET   "paste_edit"

The actual paths are defined by the containing app; these are just examples.

=head1 RATIONALE

There are many nice pastebins available, but I want something that embeds into
a bigger app and supports extensions for easy transfers to/from other apps.

If instead you are looking for a standalone pastebin, I strongly recommend
https://github.com/jhthorsen/app-mojopaste by Jan Henning Thorsen.

=head1 CONTRIBUTORS

Whenever you write something on top of Mojolicious, making use of the Mojo
tools, you are almost embarrassed how little extra you need to write.  So, as
ever, Sebastian Riedel is unwittingly the main contributor.

This implementation blatantly piggy-backs on the discussions of Jan Henning
Thorsen.

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2014, Nic Sandfield.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.
