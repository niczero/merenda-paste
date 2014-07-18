package ExampleApp;
use Mojo::Base 'Mojolicious';

use Mojo::Util 'slurp';

# Public methods

sub startup {
  my $self = shift;
  # Adjust 'home' to be parent of 'test'; not needed for real apps
  my $home = $self->home->parse($self->home->rel_dir('..'));

  $self->defaults(title => 'ExampleApp :: Paste', layout => 'default');
  $self->plugin(Config => { file => $home->rel_file('cfg/example_app.conf') });
  push @{$self->renderer->classes}, __PACKAGE__;
  $self->secrets(['t3sting']);

  $self->plugin('Merenda::Paste' => $self->config->{paste});

  # Router
  my $r = $self->routes;
  $r->get('/paste')                             ->name('paste_main');
  $r->post('/paste')->to('Paste#create')        ->name('paste_create');
  $r->get('/paste/:paste_id')->to('Paste#show', template => 'paste_show')
                                                ->name('paste_show');
  $r->get('/paste/:paste_id/edit')->to('Paste#edit', template => 'paste_main')
                                                ->name('paste_edit');
}

1;
__DATA__
@@ layouts/default.html.ep
<!DOCTYPE>
<html>
<head>
<title><%= title %></title>
<meta name="description" content="An integrated pastebin">
</head>

<body>
<%= content %>
<script src="//google-code-prettify.googlecode.com/svn/loader/run_prettify.js?autoload=true&skin=sons-of-obsidian"></script>
</body>
</html>
