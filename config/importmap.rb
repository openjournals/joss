# Pin npm packages by running ./bin/importmap

pin "application", preload: true

pin_all_from "app/javascript/custom", under: "custom"

# Chartkick
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

# ClipboardJS
pin "clipboard.js", to: "https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.10/clipboard.min.js", preload: true

# JQuery
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.6.0/dist/jquery.js", preload: true
pin "jquery-ujs", to: "https://ga.jspm.io/npm:jquery-ujs@1.2.3/src/rails.js", preload: true

# Bootstrap
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@4.3.1/dist/js/bootstrap.js", preload: true
pin "popper.js", to: "https://ga.jspm.io/npm:popper.js@1.16.1/dist/umd/popper.js", preload: true