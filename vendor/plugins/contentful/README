= Contentful

Contentful is a Rails plugin to make it easy to write tests that
compare the HTML content of rendered views against expected content
stored in files, and to create, compare against, and update that
expected content.

== Installation

Contentful should be installed as a plug-in to a Rails app:

  ~rails_app$ script/plugin install svn://rubyforge.org/var/svn/contentful 

As usual for plug-in installation, if <tt>vendor/plugins</tt> is
already under Subversion source control, this will add Contentful as
<tt>svn:external</tt>; otherwise it just copies it.

To test the plugin, you should run

  ~rails_app/vendor/plugins/contentful$ rake

or

  ~rails_app$ rake test:plugins

== Assertions

The core of Contentful is the <tt>assert_contentful</tt> method mixed
into Test::Unit::TestCase. When called without arguments from one of
your functional or integration tests, this assertion checks the
rendered HTML page content (in <tt>@response.body</tt>) against
expected content stored as an <tt>expected.html</tt> file on disk.

Files for assertions made in <tt>SomeExampleTest#test_method</tt> live
in the directory <tt>test/contentful/some_example/method/</tt>.

The assertion compares the content as HTML::Nodes, which normalizes
case, spacing and quoting within the mark-up.

If the assertion fails, then the changed content is written out as a
temporary <tt>changed.html</tt> file along with
<tt>expected.to_diff</tt> and <tt>changed.to_diff</tt> versions of the
content for comparison with a line-based diff program. When the
assertion passes, any existing temporary files are removed.

If no expected content yet exists, the assertion passes and noisily
creates expected content from the current content as a side effect.

== Extensions

An optional last argument to <tt>assert_contentful</tt> supplies a
Symbol as a label. This label is prefixed to the associated content
files. If you use two assertions in the same test, Contentful will
complain unless you supply labels to distinguish them.

An optional first argument to <tt>assert_contentful</tt> supplies an
HTML::Node to use instead of the <tt>@response.body</tt>.

To check only part of the response, use <tt>select_contentful</tt>
instead and supply a CSS selector. By default the selector is used as
a label, but you can supply one yourself to override this.

Contentful works with XML responses as well as HTML ones, putting
content into <tt>expected.xml</tt> and <tt>changed.xml</tt> files.

== Workflow

To get value from these sort of tests, you need to be able to manage
changes to content effectively. Contentful attempts to make it easy to
review such changes and accept them when appropriate.

When a Contentful assertion fails, it displays a diff command-line to
inspect the change. (Set your <tt>DIFF</tt> environment variable to
alter the program used for diffing from the default <tt>diff</tt>.)

To accept an individual change, you _could_ copy the changed content
over the expected content; but since expected content is created when
absent, a handy shortcut is to delete the current expected content and
re-run the test.

Alternatively, you can also use Rake to test, diff and accept
changes. The <tt>contentful:test</tt> task (also available as the
shorter <tt>test:content</tt>) inspects the current directory
structure within <tt>test/contentful</tt> and runs the corresponding
subset of your functional and integration tests;
<tt>contentful:diff</tt> (or <tt>test:diff</tt>) runs your diff
program on all changes currently present; and
<tt>contentful:accept</tt> (or <tt>test:accept</tt>) updates expected
content with current changes. You can run any of these tasks within a
subdirectory of <tt>test/contentful</tt> to limit their scope.

== Virtues and Vises

So-called regression tests have something of a bad name. (Literally -
hence my referring to them as "content" tests here.) They can lead you
to a place where the expectations of too many tests are trivially
broken in passing. Failing tests should tell you something useful, and
be quick to accept your judgement if all is well; poorly conceived
regression tests can instead be expensive to maintain.

But it doesn't have to be that way.

The workflow section above describes Contentful's attempt to minimize
the maintainence cost, and you can build on this for your particular
needs. When expecting changes to content, a quick eyeball or grep of
the resulting diffs is often all the feedback you need before
accepting them. Heavier lifting can be assisted by better machinery: a
previous successful set of content tests for a team project involved a
little file-associated scripting to select, diff and accept multiple
changes from within a file browser GUI.

Additionally, you can DRY up your content expectations using
<tt>select_contentful</tt> to e.g. avoid duplicating the testing of
the content of navigational sidebars across every test.

Personally, I like to keep my content tests fully live, and to
minimize then pay their maintainence tax - their pedantry catches
accidental errors surprisingly often. But even if you're not convinced
of their permanent virtue, you can still use content tests as a
temporary vice.

That is a British pun - outside of the UK, the term
(due[http://www.artima.com/weblogs/viewpost.jsp?thread=171323] to
Michael Feathers) is spelled "vise." The idea of a coding vise is to
temporarily add machinery (such as
sensing&nbsp;variables[http://www.artima.com/weblogs/viewpost.jsp?thread=170799])
to lock down a behaviour that you wish to preserve, perform a
pervasive/risky refactoring, and then remove the machinery before
checking your changes in.

Contentful serves as a very powerful vise for changes such as
refactoring your form builders, or moving from eRB to a nicer
templating system such as a
slim&nbsp;builder[http://anthonybailey.livejournal.com/29792.html]
like Markaby[http://markaby.rubyforge.org]. These kinds of change can
break your content in a variety of unexpected ways. You can protect
yourself very cheaply, covering everything generated in all existing
tests by adding the following to your <tt>config/environment.rb</tt>

  CONTENTFUL_AUTO = true

Having run tests once to generate expected content, you can
make your changes, observe, fix or accept the consequences, and remove
the Contentful vise when you're done.

== Meta

[version] 0.82
[platforms] Originated under Ubuntu and WinXP with Ruby 1.8.5 and Rails 1.2.3. Small update in Contentful 0.81 for plugin's own test suite to support Rails 2.0.x. Should work across other OS, but touches the file system, so I would like confirmation - please run tests and for real, and tell me! May not work with Ruby 1.8.4 due to an issue with <code>pathname</code> - perhaps fixable, but use at least 1.8.5 for now. Should work with older Rails versions. The <code>select_contentful</code> extension relies on <code>assert_select</code>, which was added in Rails 1.2.
[author] Anthony Bailey (mailto:mail@anthonybailey.net)
[etymology] The name of the plug-in is not "Simply Contentful", but simply "Contentful" - I allude, but would not presume.
[website] http://contentful.rubyforge.org
[development] http://rubyforge.org/projects/contentful (CHANGELOG[http://viewvc.rubyforge.mmmultiworks.com/cgi/viewvc.cgi/CHANGELOG?root=contentful&view=co])
