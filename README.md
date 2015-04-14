# dashicz
Dashicz is [Dashing.io](http://dashing.io) (nice dashboard) for [Domoticz](domoticz.com) (home automation), [and looks something like this](https://cloud.githubusercontent.com/assets/1765949/6875062/839ee1b6-d4bc-11e4-9b1a-1b08cb4419b4.png). It doesn't need a server, you simply unpack it in the domoticz/www directory, and manage the dashboard by editing the example html file. It's purpose is a nice user friendly dashboard to control your house from a tablet for instance.

# Impatient?
Run:
```
cd domoticz/www
git clone https://github.com/maartenbreddels/dashicz --recursive
cd dashicz
cp example.html index.html
```
Open [http://localhost:8080/dashicz/index.html](http://localhost:8080/dashicz/index.html)

# Installing
## Get the source
```
cd domoticz/www
git clone https://github.com/maartenbreddels/dashicz --recursive
```
The recusive part makes sure you also get dashing.io

## Edit the html file
You may want to copy example.html to index.html
```
cp example.html index.html
````
Edit the index.html, and you are done! Now open your browser and point it to (probably)
[http://localhost:8080/dashicz/index.html](http://localhost:8080/dashicz/index.html)

# Developing

## Install python libraries
This is fool proof, assuming you have python.
```
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
~/.local/bin/pip pScss coffeescript --user
```
Otherwise, simpy do:
```
sudo pip pScss coffeescript
```

## Install coffeescript
```
sudo apt-get install nodejs npm
```
I couldnt get coffee-script install over https, this fixed it
```
sudo npm config set registry http://registry.npmjs.org/
sudo npm install coffee-script
```
## Generate javascript and css
```
python compile.py 
```

# Test it out
Go to http://youserver:yourport/dashicz/example.html , possibly  [http://localhost:8080/dashicz/example.html](http://localhost:8080/dashicz/example.html)

# What now?
Dashicz doesn't come with an editor or whatever, copy example.html to index.html (or something else), and edit it.
# How it works
* Using ajax we get poll the device changes in domoticz
* Using Dashing.io we have `<div data-id="Dummy" data-view="Switch"></div>`, which links the Domoticz switch named Dummy to a widget called 'Switch'.
* dashicz/widgets/switch contains switch.coffee/html/scss, which defines the whole widget
* compile.py compiles all the coffeescript and scss into javascript and css.
* On top of that you can also have composite widgets, thermostate_room and status are examples
* Use the source!
* Contributions welcome, otherwise fork!
  
# Usefull tips
## Auto recompile
If you edit any of the js/coffeescript or css/scss files, compile.py needs to be run. Automate this by installing watchdog, it can monitor file changes and execute a command when something changes.
```
pip install watchdog
```
Now execute this:
```
watchmedo shell-command --patterns="*.scss;*.js;*.coffee"     --recursive     --command='python compile.py' -W
```
## Making a new widget
 * Run `sh new_widget.sh switch foo` to create a widget called foo based on switch, or do the following:
  * Create widgets/foo/foo.coffee (and have a class Dashing.Foo, see other widgets for an example)
  * Create widgets/foo/foo.html 
  * Create widgets/foo/foo.scss (make sure it starts with `.widget-foo {` )
 * Add "foo" to the list in compile.py
 * Execute compile.py
 * Add <div data-id="Your domociz device name" data-view="Foo"/> to index.html 
 * Use the source!
 
