const {environment} = require('@rails/webpacker')
const ProvidePlugin = require('webpack/lib/ProvidePlugin')

// add providePlugin for jQuery
environment.plugins.prepend(
    'Provide',
    new ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        jquery: 'jquery'
    })
)

// add jquery alias
const customConfig = {
    resolve: {
        alias: {
            jquery: 'jquery/src/jquery'
        }
    }
}
environment.config.merge(customConfig)

// add resolve-url-loader
environment.loaders.get('sass').use.splice(-1, 0, {
    loader: 'resolve-url-loader',
    options: {
        attempts: 1
    }
});

module.exports = environment
