## Getting Started
```sh
cd src
npm install && bundle install && bower install
grunt serve
```

## Local Development

### Pager
This project uses Pager to support local development.  Pager is a utility that launches a local webserver and serves Pages templates.  This project expects that `$GOPATH` is set and the pager binary is available at `$GOPATH/src/yext/pages/storepages/scripts/pager/pager`

### Grunt Tasks

* `grunt serve`  Performs a development build, then launches `pager`.  Sets up a Grunt watcher for faster iteration. Use --port=[PORT] to specify a port.
* `grunt serve:dist`  Performs a production build, then launches `pager`.  Useful for previewing an close appromixation of the site once its deployed.
* `grunt build`  Performs a production build.  Make sure this gets run before commiting code that will get deployed to Pages.
* `grunt clean`  Removes any assets that can be regenerated (`src/.tmp`, `/desktop/css`, `/desktop/js`, etc.)

### LiveReload
[LiveReload](https://github.com/gruntjs/grunt-contrib-watch#optionslivereload) is included in the `watch` task.  You'll need the [LiveReload Chrome Extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei) in order to take advantage.

Note: The watch task uses a port that is the pagerPort plus 10,000, e.g. 19027. So don't choose a pager port number that's greater than about 50,000 to be safe.

### Grunt Git Hooks
You can now optionally enable Git hooks powered by Grunt. See grunt-githooks for details on how the project works: https://github.com/rhumaric/grunt-githooks .

This project includes a pre-commit hook that will run the Clean and Build tasks every time you commit.  This ensures that you always get your build files updated so the build doesn't fail on Jenkins.

To install run `grunt githooks` which will automagically set everything up for you.  *You must have already run `git init` for this to work*.

*Also, please ensure that your $PATH is properly setup in your ~/.bash_profile*

## Notes
* bower-jvectormap is a clone of this repo: https://github.com/bjornd/jvectormap