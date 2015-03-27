import logging
import json
import os

logging.basicConfig()
log = logging.getLogger(__name__)

widgets = "thermostate_room status graph switch text".split()

def js():
	import coffeescript
	nizzle = True
	if not nizzle:
		scripts = ['assets/javascripts/application.js']
	scripts = [
		'javascript/jquery.js',
		'dashing/javascripts/es5-shim.js',
		'dashing/templates/project/assets/javascripts/d3-3.2.8.js',

		'dashing/javascripts/batman.js',
		'dashing/javascripts/batman.jquery.js',

		'dashing/templates/project/assets/javascripts/gridster/jquery.gridster.js',
		'dashing/templates/project/assets/javascripts/gridster/jquery.leanModal.min.js',

		'javascript/jquery-ui.js',

		'javascript/dashicz.coffee',
		'dashing/templates/project/assets/javascripts/dashing.gridster.coffee',

		'dashing/templates/project/assets/javascripts/jquery.knob.js',
		'dashing/templates/project/assets/javascripts/rickshaw-1.4.3.min.js',
		'dashing/templates/project/assets/javascripts/application.coffee',
		'javascript/application_dashicz.coffee',
		]

	for name in widgets:
		scripts.append(os.path.join("widgets", name, name+".coffee"))
	output = []
	for path in scripts:
		output.append('// JS: %s\n' % path)
		if '.coffee' in path:
			log.info('Compiling Coffee for %s ' % path)
			contents = coffeescript.compile_file(path)
		else:
			f = open(path)
			contents = f.read()
			f.close()

		output.append(contents)

	if nizzle:
		f = open('/tmp/foo.js', 'w')
		for o in output:
			print >> f, o
		f.close()

		f = open('/tmp/foo.js', 'rb')
		output = f.read()
		f.close()
		#current_app.javascripts = output
	#else:
	#	current_app.javascripts = ''.join(output)
		
	fn = os.path.join(os.path.dirname(__file__), "all.js")
	print "writing", fn
	file(fn, "w").write("".join(output))

import StringIO
from scss import Scss

def css():
	css_filenames = [
		#'assets/stylesheets/application.css',
		"css/jquery-ui.css",
		'dashing/templates/project/assets/stylesheets/application.scss',
		'dashing/templates/project/assets/stylesheets/jquery.gridster.css',
	]
	for name in widgets:
		css_filenames.append(os.path.join("widgets", name, name+".scss"))
	css_output = StringIO.StringIO()
	for fn in css_filenames:
		if fn.endswith("scss"):
			css = Scss()
			print "compile", fn
			css_output.write(css.compile(open(fn).read()))
		else:
			print "append", fn
			css_output.write(file(fn).read())
	print "writing all.css"
	file("all.css", "w").write(css_output.getvalue())
	
js()
css()
