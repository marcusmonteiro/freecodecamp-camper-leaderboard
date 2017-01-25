require('sanitize.css/sanitize.css')
require('./main.css')
var Elm = require('./Main.elm')

var root = document.getElementById('root')

Elm.Main.embed(root)
