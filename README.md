# elm-webpack-starter


### About:
A simple Webpack project for writing [Elm](http://elm-lang.org/) apps

* Dev server with live reloading, HMR
* Support for Stylus
* Bundling and minification for deployment
* Basic app, using `Html.beginnerProgram`


### Serve locally:
```
npm start
```
* Access app at `http://localhost:8080/`
* Get coding! The entry point file is `src/elm/Main.elm`
* Browser will refresh automatically on any file changes..


### Build & bundle for prod:
```
npm run build
```

* Files are saved into the `/dist` folder
* To check it, open `dist/index.html`

### Deploy (route 53, subdomain example; other options should be fine as very simple `dist/` )
```
gulp deploy
```

Having configured/created aws-config.json

Needs S3 bucket ID (which matches sub domain)

configuration of route 53

create record set
name (must match s3 id)
choose alias
target should appear as option if subdomain + s3 bucket name match

will take a few minutes to actually work

### Alternative deployments

Whatever option selected must ensure that serving from route as js url is relative to `/` i.e. treat `dist` as root.